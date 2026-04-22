# fastani

`fastani` is a minimal container image for **FastANI**, a fast alignment-free method to estimate Average Nucleotide Identity (ANI) between genomes.

## Source and version

- Upstream project: https://github.com/ParBLiSS/FastANI
- Container builds from upstream source tarball release
- Current version in `Dockerfile`: `v1.34`

## Usage

Run the tool directly (the container entrypoint is `fastANI`):

```bash
docker run --rm -v "$(pwd):/data" picotainers/fastani:latest --help
```

Typical ANI run example:

```bash
docker run --rm -v "$(pwd):/data" picotainers/fastani:latest \
  --query /data/query.fa \
  --ref /data/reference.fa \
  --output /data/ani.out
```

## Building

```bash
docker build -t picotainers/fastani:latest .
```

For local smoke testing:

```bash
docker build -t picotainers/fastani:test .
```

## Testing

Smoke test the CLI:

```bash
docker run --rm picotainers/fastani:test --help
```

Optional version check:

```bash
docker run --rm picotainers/fastani:test --version
```

## Notes

- Image is multi-stage: build on `debian:bookworm-slim`, runtime on distroless Debian 12.
- Working directory inside container: `/data`.
