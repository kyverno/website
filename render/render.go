package main

import (
	"encoding/json"
	"fmt"
	"github.com/go-git/go-billy/v5/memfs"
	kyvernov1 "github.com/kyverno/kyverno/pkg/api/kyverno/v1"
	"io/ioutil"
	"k8s.io/apimachinery/pkg/util/yaml"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"
)

type gitInfo struct {
	u      *url.URL
	owner  string
	repo   string
	branch string
}

type policyData struct {
	Title  string
	Weight int
	Policy *kyvernov1.ClusterPolicy
	YAML   string
	RawURL string
	Path   string
}

func newPolicyData(p *kyvernov1.ClusterPolicy, weight int, rawYAML, rawURL, path string) *policyData {
	return &policyData{
		Title:  buildTitle(p),
		Weight: weight,
		Policy: p,
		YAML:   rawYAML,
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
	title = strings.ReplaceAll(name, "_", " ")
	return strings.Title(title)
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

	weight := 1
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
			log.Printf("failed to decode policy: %v", err)
			continue
		}

		if !(policy.TypeMeta.Kind == "ClusterPolicy" || policy.TypeMeta.Kind == "Policy") {
			log.Printf("%s is not a Policy or a ClusterPolicy", yamlFilePath)
			continue
		}

		relPath := strings.ReplaceAll(yamlFilePath, "\\", "/")
		pathElems := []string{git.owner, git.repo, "raw", git.branch, relPath}
		rawURL := "https://github.com/" + strings.Join(pathElems, "/")

		pd := newPolicyData(policy, weight, string(bytes), rawURL, relPath)
		outFile, err := createOutFile(filepath.Dir(yamlFilePath), outdir, filepath.Base(file.Name()))
		if err != nil {
			return err
		}

		if err := t.Execute(outFile, pd); err != nil {
			log.Printf("ERROR: failed to render policy %s: %v", policy.Name, err.Error())
			continue
		}

		log.Printf("rendered %s", outFile.Name())
		weight++
	}

	return nil
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
