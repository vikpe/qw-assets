TMP_DIR="scripts/tmp"
QTOOLS_DIR="${TMP_DIR}/qtools"
SVGCLEANER_URL="https://github.com/RazrFalcon/svgcleaner/releases/download/v0.9.5/svgcleaner_linux_x86_64_0.9.5.tar.gz"
SVGCLEANER_PATH="${TMP_DIR}/svgcleaner"

if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

# quake-cli-tools
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

# svgcleaner
if [ ! -f ${SVGCLEANER_PATH} ]; then
  wget ${SVGCLEANER_URL} -O ${SVGCLEANER_PATH}.tar.gz
  tar -xvf ${SVGCLEANER_PATH}.tar.gz -C ${TMP_DIR}
  rm ${SVGCLEANER_PATH}.tar.gz
fi

# generate svg and json files
for MAPDIR in maps/*; do
  MAPNAME=$(basename ${MAPDIR})

  # svg
  if [ -f ${MAPDIR}/${MAPNAME}.bsp ]; then
     if [ ! -f ${MAPDIR}/${MAPNAME}.svg ]; then
      ${TMP_DIR}/qtools/dist/bsp2svg/bsp2svg ${MAPDIR}/${MAPNAME}.bsp -d ${MAPDIR}/${MAPNAME}.svg
      ${SVGCLEANER_PATH} ${MAPDIR}/${MAPNAME}.svg ${MAPDIR}/${MAPNAME}.svg
    fi
  fi

  # json
  if [ ! -f ${MAPDIR}/${MAPNAME}.json ]; then
    cp scripts/info_template.json ${MAPDIR}/${MAPNAME}.json
  fi
done

# list missing bsp files
for MAPDIR in maps/*; do
  MAPNAME=$(basename ${MAPDIR})

  if [ ! -f ${MAPDIR}/${MAPNAME}.bsp ]; then
    echo "* Missing file: ${MAPDIR}/${MAPNAME}.bps"
  fi
done
