package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"text/template"

	"github.com/go-git/go-billy/v5/memfs"
	kyvernov1 "github.com/kyverno/kyverno/pkg/api/kyverno/v1"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
	"k8s.io/apimachinery/pkg/util/yaml"
)

type gitInfo struct {
	u      *url.URL
	owner  string
	repo   string
	branch string
}

type policyData struct {
	Title  string
	Policy *kyvernov1.ClusterPolicy
	YAML   string
	Type   string
	RawURL string
	Path   string
}

func stringContains(rawString string, substring string) bool {
	hasString := strings.Index(rawString, substring)
	return hasString >= 0
}

func getPolicyType(yaml string) string {
	generate := "generate"
	mutate := "mutate"
	validate := "validate"
	verifyImages := "verifyImages"

	if stringContains(yaml, generate) {
		return generate
	} else if stringContains(yaml, mutate) {
		return mutate
	} else if stringContains(yaml, validate) {
		return validate
	} else {
		return verifyImages
	}
}

func newPolicyData(p *kyvernov1.ClusterPolicy, rawYAML, rawURL, path string) *policyData {
	return &policyData{
		Title:  buildTitle(p),
		Policy: p,
		YAML:   rawYAML,
		Type:   getPolicyType(rawYAML),
		RawURL: rawURL,
		Path:   path,
	}
}

func buildTitle(p *kyvernov1.ClusterPolicy) string {
	name := p.Annotations["policies.kyverno.io/title"]
	if name != "" {
		return name
	}

	name = p.Name
	title := strings.ReplaceAll(name, "-", " ")
	title = strings.ReplaceAll(title, "_", " ")

	return cases.Title(language.Und, cases.NoLower).String(title)
}

func render(git *gitInfo, outdir string) error {
	repoURL := git.u.String()
	fs := memfs.New()
	_, err := clone(repoURL, fs)
	if err != nil {
		return fmt.Errorf("failed to clone repository %s: %v", repoURL, err)
	}

	yamls, err := listYAMLs(fs, "/")
	if err != nil {
		return fmt.Errorf("failed to list YAMLs in repository %s: %v", repoURL, err)
	}

	sort.Strings(yamls)
	log.Printf("retrieved %d YAMLs in repository %s", len(yamls), repoURL)

	t := template.New("policy")
	t, err = t.Parse(policyTemplate)
	if err != nil {
		return fmt.Errorf("failed to parse template: %v", err)
	}

	if Clean {
		err := deleteMarkdownFiles(outdir)
		if err != nil {
			return fmt.Errorf("failed to clean directory %s: %v", outdir, err)
		}
	}

	for _, yamlFilePath := range yamls {
		file, err := fs.Open(yamlFilePath)
		if err != nil {
			log.Printf("Error: failed to read %s: %v", yamlFilePath, err.Error())
			continue
		}

		bytes, err := ioutil.ReadAll(file)
		if err != nil {
			log.Printf("Error: failed to read file %s: %v", file.Name(), err.Error())
		}

		policyBytes, err := yaml.ToJSON(bytes)
		if err != nil {
			log.Printf("failed to convert to JSON: %v", err)
			continue
		}

		policy := &kyvernov1.ClusterPolicy{}
		if err := json.Unmarshal(policyBytes, policy); err != nil {
			if Verbose {
				log.Printf("failed to decode file %s: %v", yamlFilePath, err)
			}

			continue
		}

		if !(policy.TypeMeta.Kind == "ClusterPolicy" || policy.TypeMeta.Kind == "Policy") {
			continue
		}

		if !strings.HasPrefix(policy.APIVersion, "kyverno.io/") {
			if Verbose {
				log.Printf("skipping non-Kyverno policy resource: %s/%s", policy.APIVersion, policy.Kind)
			}

			continue
		}

		relPath := strings.ReplaceAll(yamlFilePath, "\\", "/")
		pathElems := []string{git.owner, git.repo, "raw", git.branch, relPath}
		rawURL := "https://github.com/" + strings.Join(pathElems, "/")
		rawURL = trimDoubleSlashes(rawURL)

		pd := newPolicyData(policy, string(bytes), rawURL, relPath)
		outFile, err := createOutFile(filepath.Dir(yamlFilePath), outdir, filepath.Base(file.Name()))
		if err != nil {
			return err
		}

		if err := t.Execute(outFile, pd); err != nil {
			log.Printf("ERROR: failed to render policy %s: %v", policy.Name, err.Error())
			continue
		}

		if Verbose {
			log.Printf("rendered %s", outFile.Name())
		}
	}

	return nil
}

// deleteMarkdownFiles deletes all .md files except "_index.md"
func deleteMarkdownFiles(outdir string) error {
	d, err := os.Open(outdir)
	if err != nil {
		return err
	}

	defer d.Close()
	files, err := d.Readdir(-1)
	if err != nil {
		return err
	}

	if Verbose {
		log.Printf("cleaning directory %s", outdir)
	}

	for _, file := range files {
		if file.Mode().IsRegular() {
			name := file.Name()
			if filepath.Ext(name) == ".md" {
				if filepath.Base(name) == "_index.md" {
					continue
				}

				os.Remove(file.Name())
			}
		}
	}

	return nil
}

var regexReplaceDoubleSlashes = regexp.MustCompile("/([^:])(//+)/g")

func trimDoubleSlashes(rawURL string) string {
	return regexReplaceDoubleSlashes.ReplaceAllLiteralString(rawURL, "/")
}

func createOutFile(inDir, outDir, fileName string) (*os.File, error) {
	path := filepath.Join(outDir, inDir)
	if err := os.MkdirAll(path, 0744); err != nil {
		return nil, fmt.Errorf("failed to create path %s", path)
	}

	out := filepath.Join(path, strings.ReplaceAll(fileName, filepath.Ext(fileName), ".md"))
	outFile, err := os.Create(out)
	if err != nil {
		return nil, fmt.Errorf("failed to create file %s: %v", path, err)
	}

	return outFile, nil
}
