#### Usage

`bash parser.sh schema.csv | tee _parser.sh` creates `_parser.sh`: parser program tailored for given schema
`bash run.sh arguments.txt` creates `_arguments.yaml`: YAML representation of parsed params

`bash parser.sh schema.csv | tee _parser.sh | bash run.sh arguments.txt` performs both