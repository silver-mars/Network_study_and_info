List content of jks:
```
keytool -v -list -keystore your_keystore -storepass pass
```
Export key from jks:
```
keytool -exportcert -keystore backup.jks -alias certificate -file certus.cer
```

