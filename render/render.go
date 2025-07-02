package main

import (
	"encoding/json"
	"fmt"
	"io"
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
	"sigs.k8s.io/yaml" 
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

func yamlContainsPolicy(rawString string, substring string) bool {
	hasString := strings.Index(rawString, (substring + ":"))
	return hasString >= 0
}

func yamlContainsKyvernoCR(rawString string, kind string) bool {
	hasKind := strings.Index(rawString, ("kind: " + kind))
	return hasKind >= 0
}
func extractKind(yamlStr string) string {
	var meta struct {
		Kind string `yaml:"kind"`
	}
	_ = yaml.Unmarshal([]byte(yamlStr), &meta)
	return meta.Kind
}

func extractSpec(yamlStr string) string {
	var obj map[string]interface{}
	if err := yaml.Unmarshal([]byte(yamlStr), &obj); err != nil {
		return ""
	}
	if spec, ok := obj["spec"]; ok {
		specBytes, _ := yaml.Marshal(spec)
		return string(specBytes)
	}
	return ""
}


func getPolicyType(yamlStr string) string {
	kind := extractKind(yamlStr)
	spec := extractSpec(yamlStr)

	switch kind {
	case "ClusterPolicy":
		switch {
		case yamlContainsPolicy(spec, "generate"):
			return "generate"
		case yamlContainsPolicy(spec, "mutate"):
			return "mutate"
		case yamlContainsPolicy(spec, "validate"):
			return "validate"
		case yamlContainsPolicy(spec, "verifyImages"):
			return "verifyImages"
		}
	case "GeneratePolicy":
		return "generate"
	case "CleanupPolicy", "ClusterCleanupPolicy", "DeletePolicy":
		return "cleanUp"
	case "ValidatingPolicy":
		return "validate"
	case "ImageValidatingPolicy":
		return "verifyImages"
    case "MutatePolicy" :
		return "mutate"
	
	}
	return ""
}

func newPolicyData(p *kyvernov1.ClusterPolicy, rawYAML, rawURL, path string) *policyData {
	if !hasKyvernoAnnotation(p) {
		return nil
	}

	return &policyData{
		Title:  buildTitle(p),
		Policy: p,
		YAML:   rawYAML,
		Type:   getPolicyType(rawYAML),
		RawURL: rawURL,
		Path:   path,
	}
}

func hasKyvernoAnnotation(p *kyvernov1.ClusterPolicy) bool {
	for k := range p.Annotations {
		if strings.HasPrefix(k, "policies.kyverno.io") {
			return true
		}
	}
	return false
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

		err = removeEmptyDirs(outdir)
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

		bytes, err := io.ReadAll(file)
		if err != nil {
			log.Printf("Error: failed to read file %s: %v", file.Name(), err.Error())
		}

		policyBytes, err := yaml.YAMLToJSON(bytes)
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

		if !strings.HasPrefix(policy.APIVersion, "kyverno.io/") && !strings.HasPrefix(policy.APIVersion, "policies.kyverno.io/") {
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

		if pd == nil {
			continue
		}
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

// removeEmptyDirs collects directories and deletes empty ones from deepest to shallowest
func removeEmptyDirs(dir string) error {
	var dirs []string

	// First, traverse the directory tree to collect directories
	err := filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			dirs = append(dirs, path)
		}
		return nil
	})
	if err != nil {
		return err
	}

	// Sort directories by depth (deepest directories first)
	sort.Slice(dirs, func(i, j int) bool {
		return len(dirs[i]) > len(dirs[j])
	})

	// Attempt to delete directories, starting from the deepest
	for _, path := range dirs {
		empty, err := isEmptyDir(path)
		if err != nil {
			return err
		}
		if empty {
			if Verbose {
				log.Printf("Removing empty directory: %s\n", path)
			}
			err := os.Remove(path)
			if err != nil {
				fmt.Printf("Failed to remove directory %s: %v", path, err)
			}
		}
	}

	return nil
}

// isEmptyDir checks if a directory is empty
func isEmptyDir(dirPath string) (bool, error) {
	entries, err := os.ReadDir(dirPath)
	if err != nil {
		return false, err
	}
	return len(entries) == 0, nil
}

// deleteMarkdownFiles deletes all .md files except "_index.md"
func deleteMarkdownFiles(outdir string) error {
	// Walk through the directory and its subdirectories
	err := filepath.WalkDir(outdir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Process only files
		if d.IsDir() {
			return nil
		}

		name := d.Name()
		if filepath.Ext(name) == ".md" {
			// Skip _index.md files
			if filepath.Base(name) == "_index.md" {
				return nil
			}

			if err := os.Remove(path); err != nil {
				if Verbose {
					log.Printf("failed to delete file %s: %v", path, err)
				}
			}
		}

		return nil
	})

	if err != nil {
		return err
	}

	if Verbose {
		log.Printf("cleaned directory %s", outdir)
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
