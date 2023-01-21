is_multiple=()
is_flag=()
all_flags=()
all_names=()

script_pre="${script_pre}POSITIONAL_ARGS=()"

script+="\nwhile [[ \"\$#\" -gt 0 ]]; do"
script+="\n    case \$1 in" 

while read IN; do

    arr=(${IN//,/ })

    alias="${arr[0]}"
    name="${arr[1]}"
    nargs="${arr[2]}"
    
    all_names+=("${name}")

    if [[ $nargs = "+" ]]; then
        is_multiple+=("True")
        script_pre="${script_pre}\n$name=()"
    else
        is_multiple+=("")
    fi        

    if [[ $nargs = "0" ]]; then
        is_flag+=("True")
    else 
        is_flag+=("")
    fi


    if [[ $nargs = "0" ]]; then 

        script+="\n        -${alias}|--${name})"
        script+="\n            ${name}=True"
        script+="\n            shift"
        script+="\n            ;;"
        
        all_flags+=("${alias},${name}")

    elif [[ $nargs = "1" ]]; then

        script+="\n        -${alias}|-${alias}=*|--${name}|--${name}=*)"
        script+="\n            if [[ \$1 = \"-${alias}\" || \$1 = \"--${name}\" ]]; then"
        script+="\n                ${name}=\"\$2\""
        script+="\n                shift"
        script+="\n                shift"
        script+="\n            else"
        script+="\n                ${name}Arg=(\${1//=/ })"
        script+="\n                ${name}=\"\${${name}Arg[1]}\""
        script+="\n                shift"
        script+="\n            fi"
        script+="\n            ;;"
    
    elif [[ $nargs = "+" ]]; then

        script+="\n        -${alias}|-${alias}=*|--${name}|--${name}=*)"
        script+="\n            if [[ \$1 = \"-${alias}\" || \$1 = \"--${name}\" ]]; then"
        script+="\n                ${name}+=(\"\$2\")"
        script+="\n                shift"
        script+="\n                shift"
        script+="\n            else"
        script+="\n                ${name}Arg=(\${1//=/ })"
        script+="\n                ${name}+=(\"\${${name}Arg[1]}\")"
        script+="\n                shift"
        script+="\n            fi"
        script+="\n            ;;"
    
    fi

done < $1
script="${script_pre}\n${script}"
script+="\n        --*)"
script+="\n            echo \"Invalid argument: \$1\""
script+="\n            exit 1"
script+="\n            ;;"
script+="\n        -*)"
script+="\n            for i in \$(seq \${#1}); do"
script+="\n                char=\${1:\$i:1}"
script+="\n                if [[ -z \$char ]]; then"
script+="\n                    continue"
script+="\n                fi"
script+="\n                case \$char in"

for arg in ${all_flags[@]}; do
    args=(${arg//,/ })
    script+="\n                    ${args[0]})"
    script+="\n                        ${args[1]}=True"
    script+="\n                        ;;"
done

script+="\n                    *)"
script+="\n                        echo \"Invalid argument: \$char\""
script+="\n                        exit 1"
script+="\n                        ;;"
script+="\n                esac"
script+="\n            done"
script+="\n            shift"
script+="\n            ;;"
script+="\n        *)"
script+="\n            POSITIONAL_ARGS+=(\"\$1\")"
script+="\n            shift"
script+="\n            ;;"
script+="\n    esac"
script+="\ndone"
script+="\n"
script+="\necho \"args:\""
script+="\nfor arg in \${POSITIONAL_ARGS[@]}; do"
script+="\n    echo \"- \${arg}\""
script+="\ndone"
script+="\nset -- \${POSITIONAL_ARGS[@]}"
script+="\necho \"kwargs:\""

for i in $(seq 0 "${#all_names[@] - 1}"); do
    name="${all_names[i]}"
    if [[ -z ${name} ]]; then
        break
    fi
    if [[ "${is_flag[i]}" = "True" ]]; then
        script+="\necho \"  ${name}: \$([ -z \${${name}} ] && echo \"False\" || echo \"True\")\""
    elif [[ "${is_multiple[i]}" = "True" ]]; then
        script+="\necho \"  ${name}:\""
        script+="\nfor arg in \${${name}[@]}; do"
        script+="\n  echo \"  - \${arg}\""
        script+="\ndone"
    else
        script+="\necho \"  ${name}: \${${name}}\""
    fi
done

printf "${script}" | tee "_parser.sh"

