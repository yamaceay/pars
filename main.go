package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os/exec"

	"gopkg.in/yaml.v2"
)

var (
	sh    = "/bin/sh"
	build = "parser.sh"
	run   = "run.sh"
)

func Build(schema string) (p *Parser, err error) {
	if schema == "" {
		return p, errors.New("Empty schema")
	} else if err := exec.Command(sh, build, schema).Run(); err != nil {
		return p, fmt.Errorf("Failed to build arg parser: %w", err)
	}
	return &Parser{}, nil
}

type Parser struct {
}

func (*Parser) Run(arguments string) (p *Params, err error) {
	if arguments == "" {
		return p, errors.New("Empty arguments")
	} else if by, err := exec.Command(sh, run, arguments).Output(); err != nil {
		return p, fmt.Errorf("Failed to parse arguments: %w", err)
	} else if err := yaml.Unmarshal(by, &p); err != nil {
		return p, fmt.Errorf("Failed to parse YAML arguments: %w", err)
	} else if p == nil {
		return p, errors.New("Empty params")
	} else {
		return p, nil
	}
}

type Params struct {
	Args   `yaml:"args" json:"args"`
	Kwargs `yaml:"kwargs" json:"kwargs"`
}

func (p Params) String() (s string) {
	if aBy, err := json.MarshalIndent(p.Args, "", "  "); err != nil {
	} else if kBy, err := json.MarshalIndent(p.Kwargs, "", "  "); err != nil {
	} else {
		return fmt.Sprintf("args: %s\n\nkwargs: %s\n", string(aBy), string(kBy))
	}
	return s
}

type Args []interface{}
type Kwargs map[string]interface{}
