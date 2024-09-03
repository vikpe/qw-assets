TMP_DIR="scripts/tmp"
MAPMETA_DIR="${TMP_DIR}/qw-assets-mapmeta"
QTOOLS_DIR="${TMP_DIR}/qtools"
SVGCLEANER_URL="https://github.com/RazrFalcon/svgcleaner/releases/download/v0.9.5/svgcleaner_linux_x86_64_0.9.5.tar.gz"
SVGCLEANER_BIN="${TMP_DIR}/svgcleaner"

if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

# mapmeta
if [ ! -d ${MAPMETA_DIR} ]; then
  git clone git@github.com:vikpe/qw-assets-mapmeta.git ${MAPMETA_DIR}
else
  (
    cd ${MAPMETA_DIR}
    git pull
  )
fi
(
  cd ${MAPMETA_DIR}
  cargo build --release
)

mv ${MAPMETA_DIR}/target/release/mapmeta ${TMP_DIR}/mapmeta

# quake-cli-tools
if [ ! -d ${QTOOLS_DIR} ]; then
  git clone https://github.com/joshuaskelly/quake-cli-tools.git ${QTOOLS_DIR}

  (
    cd ${QTOOLS_DIR}

    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    pip install -r requirements-dev.txt
    make bsp2svg
  )
fi

# svgcleaner
if [ ! -f ${SVGCLEANER_BIN} ]; then
  wget ${SVGCLEANER_URL} -O ${SVGCLEANER_BIN}.tar.gz
  tar -xvf ${SVGCLEANER_BIN}.tar.gz -C ${TMP_DIR}
  rm ${SVGCLEANER_BIN}.tar.gz
fi

# generate svg and json files
for MAPDIR in maps/*; do
  MAPNAME=$(basename ${MAPDIR})

  # svg
  if [ -f ${MAPDIR}/${MAPNAME}.bsp ]; then
     if [ ! -f ${MAPDIR}/${MAPNAME}.svg ]; then
      ${TMP_DIR}/qtools/dist/bsp2svg/bsp2svg ${MAPDIR}/${MAPNAME}.bsp -d ${MAPDIR}/${MAPNAME}.svg
      ${SVGCLEANER_BIN} ${MAPDIR}/${MAPNAME}.svg ${MAPDIR}/${MAPNAME}.svg
    fi
  fi

  # json meta file
  if [ ! -f ${MAPDIR}/${MAPNAME}.json ]; then
    ${TMP_DIR}/mapmeta ${MAPDIR}/${MAPNAME}.bsp
  fi
done

# list missing bsp files
for MAPDIR in maps/*; do
  MAPNAME=$(basename ${MAPDIR})

  if [ ! -f ${MAPDIR}/${MAPNAME}.bsp ]; then
    echo "* Missing file: ${MAPDIR}/${MAPNAME}.bps"
  fi
done
