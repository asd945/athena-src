# athena-src

Encrypted delivery bundle for the Athena knowledge-base source stack.

## Contents

The repository tracks one Git LFS object:

```text
athena-src-20261003.tar.gz.enc
```

After decryption, the archive contains:

- source snapshots for `codegraph`, `forge`, and `athena`
- the `athena-workbench:local` `linux/amd64` image artifact
- quality-harness deployment, architecture, and usage documentation
- source provenance, per-file SHA-256 inventories, and image build metadata

## Decrypt

The passphrase is not committed. Retrieve it from the local protected file:

```text
~/workspace/athena-src/.secrets/athena-src-passphrase.txt
```

Decrypt and extract:

```sh
openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -md sha256 \
  -in athena-src-20261003.tar.gz.enc \
  -out athena-src-20261003.tar.gz \
  -pass file:/path/to/athena-src-passphrase.txt

tar -xzf athena-src-20261003.tar.gz
```

Verify the restored compressed archive before extraction:

```sh
shasum -a 256 -c SHA256SUMS
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
