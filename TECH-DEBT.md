1. Check if we need the following items in nginx:
  - `chunked_transfer_encoding off;`
  - `add_header X-Frame-Options "SAMEORIGIN";`
  - `add_header X-XSS-Protection "1; mode=block";`
  - `add_header X-Content-Type-Options nosniff;`
  - `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";`

2. Can we remove `getTag` from digicop/src/AppBundle/Twig/AssetsExtension.php ?
3. Behat requires database drivers to be installed:
  - `An exception occurred in driver: could not find driver (Doctrine\DBAL\Exception\DriverException)`
4. No codeowners file