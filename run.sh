args=()
while read IN; do
    args+=("$IN")
done < $1

out=(${1//./ })
outfile+="${out[0]}.yaml"

echo "$(bash _parser.sh ${args[@]})" | tee "_$outfile"