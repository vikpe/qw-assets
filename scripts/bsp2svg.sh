TMP_DIR="scripts/tmp"
QTOOLS_DIR="${TMP_DIR}/qtools"

rm -rf ${TMP_DIR}

if [ ! -d ${QTOOLS_DIR} ]; then
  git clone https://github.com/joshuaskelly/quake-cli-tools.git ${TMP_DIR}/qtools
  (
    cd ${TMP_DIR}/qtools

    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    pip install -r requirements-dev.txt
    make build
  )
fi

for MAPDIR in maps/*; do
  MAPNAME=$(basename ${MAPDIR})

  if [ ! -f ${MAPDIR}/${MAPNAME}.svg ]; then
    ${TMP_DIR}/qtools/dist/bsp2svg/bsp2svg ${MAPDIR}/${MAPNAME}.bsp -d ${MAPDIR}/${MAPNAME}.svg
  fi
done

rm -rf ${TMP_DIR}
