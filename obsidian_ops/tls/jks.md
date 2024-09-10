List content of jks:
```
keytool -v -list -keystore your_keystore -storepass pass
keytool -v -list -alias your_alias  -keystore your_keystore.jks

```
Export key from jks:
```
keytool -exportcert -keystore backup.jks -alias certificate -file certus.cer
# or
keytool -v -exportcert -alias your_alias -keystore your_keystore.jks -file output.crt
```

