POSITIONAL_ARGS=()
addr=()
port=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|-a=*|--addr|--addr=*)
            if [[ $1 = "-a" || $1 = "--addr" ]]; then
                addr+=("$2")
                shift
                shift
            else
                addrArg=(${1//=/ })
                addr+=("${addrArg[1]}")
                shift
            fi
            ;;
        -p|-p=*|--port|--port=*)
            if [[ $1 = "-p" || $1 = "--port" ]]; then
                port+=("$2")
                shift
                shift
            else
                portArg=(${1//=/ })
                port+=("${portArg[1]}")
                shift
            fi
            ;;
        -s|-s=*|--string|--string=*)
            if [[ $1 = "-s" || $1 = "--string" ]]; then
                string="$2"
                shift
                shift
            else
                stringArg=(${1//=/ })
                string="${stringArg[1]}"
                shift
            fi
            ;;
        -d|--default)
            default=True
            shift
            ;;
        -v|--verbose)
            verbose=True
            shift
            ;;
        -r|--read)
            read=True
            shift
            ;;
        -w|--write)
            write=True
            shift
            ;;
        --*)
            echo "Invalid argument: $1"
            exit 1
            ;;
        -*)
            for i in $(seq ${#1}); do
                char=${1:$i:1}
                if [[ -z $char ]]; then
                    continue
                fi
                case $char in
                    d)
                        default=True
                        ;;
                    v)
                        verbose=True
                        ;;
                    r)
                        read=True
                        ;;
                    w)
                        write=True
                        ;;
                    *)
                        echo "Invalid argument: $char"
                        exit 1
                        ;;
                esac
            done
            shift
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

echo "args:"
for arg in ${POSITIONAL_ARGS[@]}; do
    echo "- ${arg}"
done
set -- ${POSITIONAL_ARGS[@]}
echo "kwargs:"
echo "  addr:"
for arg in ${addr[@]}; do
  echo "  - ${arg}"
done
echo "  port:"
for arg in ${port[@]}; do
  echo "  - ${arg}"
done
echo "  string: ${string}"
echo "  default: $([ -z ${default} ] && echo "False" || echo "True")"
echo "  verbose: $([ -z ${verbose} ] && echo "False" || echo "True")"
echo "  read: $([ -z ${read} ] && echo "False" || echo "True")"
echo "  write: $([ -z ${write} ] && echo "False" || echo "True")"