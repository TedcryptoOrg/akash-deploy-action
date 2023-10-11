SEED="${{ inputs.seed }}"
PASSWORD="${{ inputs.password }}"
if test -z "${SEED}"; then
  echo "SEED is empty! Please add a mnemonic seed secret named SEED to this repo (under repo `Settings` -> `Secrets and variables` -> `Actions`)"
  exit 1
fi
if test -z "${PASSWORD}"; then
  echo "PASSWORD is empty! Please add a secret named PASSWORD to this repo (under repo `Settings` -> `Secrets and variables` -> `Actions`)"
  exit 1
fi

PW_LEN=$(echo -n "${PASSWORD}" | wc -c)
if [[ "$PW_LEN" -lt "8" ]]; then
  echo "Password is too short! It must be at least 8 characters long!"
  exit 1
fi

mkdir ~/cache 2>/dev/null || :
cd ~/cache
set -x
[[ -f ${CLIENT}_${CLIENT_VERSION}_${ARCH}.deb ]] || wget -q https://github.com/${ORG}/${REPO}/releases/download/v${CLIENT_VERSION}/${CLIENT}_${CLIENT_VERSION}_${ARCH}.deb
set +x
sudo dpkg -i ${CLIENT}_${CLIENT_VERSION}_${ARCH}.deb
${CLIENT} version

if test -z "${SEED}"; then
  echo "I could not find the mnemonic seed!"
  echo "Please add a mnemonic seed secret named SEED to this repo (under repo `Settings` -> `Secrets and variables` -> `Actions`)"
  echo "I will generate one for you as an example, using '${CLIENT} keys mnemonic' CLI command:"
  echo "============ MNEMONIC SEED ============"
  ${CLIENT} keys mnemonic
  echo "============ MNEMONIC SEED ============"
  exit 1
fi

if test -z "${PASSWORD}"; then
  echo "I could not find the password!"
  echo "Please add a secret named PASSWORD to this repo (under repo `Settings` -> `Secrets and variables` -> `Actions`)"
  echo "This password will be used to encrypt the wallet."
  exit 1
fi