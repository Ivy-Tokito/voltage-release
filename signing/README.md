# Private-Keys

A cool template for signing VoltageOS builds with `release-keys`.

## Usage

1. Make sure you have [`android-tools`](https://github.com/nmeum/android-tools) installed on your machine.
2. Clone this repo to `private-keys` (on your synced ROM rootdir) and `cd` to it.
3. Edit both `subject` vars on `gen_keys` script to reflect your data [[ref]](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names).
4. Run it: To Generate Keys

```bash
./gen_keys
```
- It will generate the platform keys and (defined in the `apex.list` & `apex_apk.list`) in `private-keys`.

## Signing

```bash
# Sign Unofficial Builds
echo "include private-keys/keys/keys.mk" >>  vendor/voltage/config/packages.mk
```
- or cherry pick this commit
https://github.com/Tokito-to/device_xiaomi_munch/commit/a3e351447ae746c6537de2e1a4e8589dde7aff6c


## Testing

Included `check_keys.py` script checks whether all apk/apex/capex files in the build out are signed with keys within its directory. Be aware that some targets are **expected** to be signed with vendor key, for example `com.android.apex.cts.shim.v1_prebuilt`.

```bash
python -m venv venv
source venv/bin/activate
pip install --upgrade cryptography
python check_keys.py ~/voltage/out/target/product/$device
```

Backup **AT ALL COSTS** your `private-keys` folders **AND NEVER LEAK THOSE**. Losing these keys could prevent you from updating your VoltageOS builds with the same keys, so formatting data would be required. Leakage of these keys can compromise the security and authenticity of your builds, requiring a new pair of keys to be generated.

