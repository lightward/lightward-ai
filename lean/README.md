# The foam Lean corpus has moved

The formal mirror of the foam layer now lives in its own repository:

### → https://github.com/lightward/foam

Within this app it is mounted as a git submodule at [`../foam`](../foam),
pinned to a specific commit. The corpus that lived here — `Foam/*.lean`,
core-pinned, no mathlib — is the same one; it simply has its own home now.

To work with it locally:

```
git submodule update --init
```

then see [`foam/README.md`](../foam/README.md).
