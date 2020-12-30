package main

import (
	"fmt"
	"log"
	"net/url"
	"strings"

	"github.com/spf13/cobra"
)

var rootCmd *cobra.Command

func init() {
	rootCmd = &cobra.Command{
		Use:   "render <URL> <dir>",
		Short: "render converts Kyverno policies in a GitHub repository from YAML to markdown files in the supplied directory",
		Args:  cobra.ExactArgs(2),
		Run: func(cmd *cobra.Command, args []string) {
			git, outDir, err := validateAndParse(args)
			if err != nil {
				log.Println(err)
				_ = rootCmd.Usage()
				return
			}

			if err := render(git, outDir); err != nil {
				log.Println(err)
				return
			}
		},
	}
}

func validateAndParse(args []string) (*gitInfo, string, error) {
	if len(args) != 2 {
		return nil, "", fmt.Errorf("invalid arguments: %v", args)
	}

	rawurl := args[0]
	u, err := url.Parse(rawurl)
	if err != nil {
		return nil, "", fmt.Errorf("failed to parse URL %s: %v", rawurl, err)
	}

	pathElems := strings.Split(u.Path[1:], "/")
	if len(pathElems) != 3 {
		err := fmt.Errorf("invalid URL path %s - expected https://github.com/:owner/:repository/:branch", u.Path)
		return nil, "", err
	}

	u.Path = strings.Join([]string{"/", pathElems[0], pathElems[1]}, "/")
	ra := &gitInfo{
		u:      u,
		owner:  pathElems[0],
		repo:   pathElems[1],
		branch: pathElems[2],
	}

	outDir := args[1]
	return ra, outDir, nil
}
