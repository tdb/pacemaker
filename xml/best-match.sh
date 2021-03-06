#!/bin/sh

base=$1; shift
target=$1; shift
destination=$1; shift
prefix=$1; shift

best="0.0"
candidates=$(ls -1 "${base}.rng" "${base}"-*.rng 2>/dev/null)
for rng in ${candidates}; do
    case ${rng} in
        ${base}-${target}.rng)
            best=${target}
            break
            ;;
        *next*)
            : skipping ${rng}
            ;;
        *)
            if [ "${rng}" = "${base}.rng" ]; then
                # special case for nvset.rng, no -0.1 around anyway
                v=0.1
            else
                v=$(echo ${rng} | sed -e "s/${base}-//" -e 's/.rng//')
            fi
            : comparing ${v} with ${target}

            echo | awk -v n1="${v}" -v n2="${best}" '{if (n1>n2) printf ("true"); else printf ("false");}' |  grep -q "true"
            if [ $? -eq 0 ]; then
                : ${v} beats the previous ${best} for ${target}
                if [ "${target}" = "next" ]; then
                    best=${v}
                else
                    echo | awk -v n1="${v}" -v n2="${target}" '{if (n1<n2) printf ("true"); else printf ("false");}' |  grep -q "true"
                    if [ $? -eq 0 ]; then
                        : ${v} is still less than ${target}, using
                        best=${v}
                    fi
                fi
            fi
            ;;
    esac
done

[ "${best}" != "0.0" ]; ec=$?
if [ ${ec} -eq 0 ]; then
    if [ "${best}" = "0.1" ]; then
        found=${base}.rng
    else
        found=${base}-${best}.rng
    fi
    if [ "x${destination}" = "x" ]; then
        echo "${found}"
    else
        echo "${prefix}<externalRef href=\"${found}\"/>" >> "${destination}"
    fi
fi
ret () { return $1; }; ret ${ec}
