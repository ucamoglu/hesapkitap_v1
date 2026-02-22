Create your upload keystore with:

```bash
keytool -genkeypair -v \
  -keystore android/keystore/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Then copy `android/key.properties.example` to `android/key.properties`
and replace the values with your real passwords.
