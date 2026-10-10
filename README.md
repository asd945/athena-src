# athena-src

Encrypted delivery bundle for the Athena knowledge-base source stack.

This repository uses ordinary Git objects only. Git LFS is not required.

## Fetch

Clone or fetch normally:

```sh
git clone git@github.com:asd945/athena-src.git
cd athena-src
```

The encrypted archive is stored as sixteen ordered chunks under `chunks/`.
Each chunk is smaller than GitHub's 100 MB per-file limit. Reassemble and
verify the encrypted archive:

```sh
bash reassemble.sh
```

This creates:

```text
athena-src-20261010.tar.gz.enc
```

## Archive Contents

After decryption, the archive contains:

- source snapshots for `forge` (latest `868fd3d`), `athena` (`8a81a80`), and `codegraph` (`af4cf8d` build/ artifacts only)
- the `athena-workbench:local` `linux/amd64` image artifact (under `images/athena-workbench/`)
- base dependency images (under `images/base/`, including `python-3.12-slim-linux-amd64.tar`)
- quality-harness deployment, architecture, and usage documentation
- source provenance, per-file SHA-256 inventories, and image build metadata under `manifests/`

## Decrypt

The passphrase is not committed. After reassembly, decrypt with:

```sh
openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -md sha256 \
  -in athena-src-20261010.tar.gz.enc \
  -out athena-src-20261010.tar.gz \
  -pass file:/path/to/athena-src-passphrase.txt

tar -xzf athena-src-20261010.tar.gz
```

The passphrase is delivered separately by the repository owner. Verify the
reassembled encrypted archive independently:

```sh
shasum -a 256 -c SHA256SUMS
(cd chunks && shasum -a 256 -c SHA256SUMS)
```

The expanded archive includes additional per-file and image-part checksums
under `manifests/`.

## Image

The image artifact is stored in its original split transport form under
`images/athena-workbench/`. On a compatible Docker host:

```sh
cd images/athena-workbench
bash reassemble.sh --load
```

The original build receipt binds the image to the source commit used at build
time. Current source snapshots are recorded separately in
`manifests/SOURCE-MANIFEST.json`.
