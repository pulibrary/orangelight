# Checking bundle size

A quick way to check the size of our production css and js (not including fonts, print styles, or third-party assets): `SECRET_KEY_BASE=fake RAILS_ENV=production be rake assets:clobber assets:precompile && ls -lh public/assets/application-*`

The output will end with something like this:

```
computing gzip size...
../../public/vite/.vite/manifest-assets.json        0.00 kB │ gzip:   0.02 kB
../../public/vite/.vite/manifest.json               0.76 kB │ gzip:   0.23 kB
../../public/vite/assets/lux_import-DaoVmB10.css  240.70 kB │ gzip:  23.71 kB
../../public/vite/assets/requests-Ciq-rNjl.js       4.71 kB │ gzip:   1.68 kB │ map:    14.56 kB
../../public/vite/assets/application-C58MRpbq.js  349.57 kB │ gzip: 110.98 kB │ map: 1,849.49 kB
../../public/vite/assets/lux_import-HJOUybCF.js   354.37 kB │ gzip: 128.70 kB │ map: 1,733.95 kB
✓ built in 1.37s
Done in 1.80s.
Build with Vite complete: /Users/sandbergj/repos/orangelight/public/vite
warning package.json: No license field

-rw-r--r--  1 sandbergj  staff   245K Nov  4 09:41 public/assets/application-25d2402f1821f54aa2a91145c0cfa48e618c52a257d044d861e857b030a502e4.js
-rw-r--r--  1 sandbergj  staff    79K Nov  4 09:41 public/assets/application-25d2402f1821f54aa2a91145c0cfa48e618c52a257d044d861e857b030a502e4.js.gz
-rw-r--r--  1 sandbergj  staff   332K Nov  4 09:41 public/assets/application-b433557e419c5e70df3223badf3f100df6fcf03a2f79d18d1a9df126413f48ea.css
-rw-r--r--  1 sandbergj  staff    49K Nov  4 09:41 public/assets/application-b433557e419c5e70df3223badf3f100df6fcf03a2f79d18d1a9df126413f48ea.css.gz
```

The important lines are:

```
../../public/vite/assets/lux_import-DaoVmB10.css  240.70 kB │ gzip:  23.71 kB
../../public/vite/assets/requests-Ciq-rNjl.js       4.71 kB │ gzip:   1.68 kB │ map:    14.56 kB
../../public/vite/assets/application-C58MRpbq.js  349.57 kB │ gzip: 110.98 kB │ map: 1,849.49 kB
../../public/vite/assets/lux_import-HJOUybCF.js   354.37 kB │ gzip: 128.70 kB │ map: 1,733.95 kB
```

and

```
-rw-r--r--  1 sandbergj  staff   245K Nov  4 09:41 public/assets/application-25d2402f1821f54aa2a91145c0cfa48e618c52a257d044d861e857b030a502e4.js
-rw-r--r--  1 sandbergj  staff    79K Nov  4 09:41 public/assets/application-25d2402f1821f54aa2a91145c0cfa48e618c52a257d044d861e857b030a502e4.js.gz
-rw-r--r--  1 sandbergj  staff   332K Nov  4 09:41 public/assets/application-b433557e419c5e70df3223badf3f100df6fcf03a2f79d18d1a9df126413f48ea.css
-rw-r--r--  1 sandbergj  staff    49K Nov  4 09:41 public/assets/application-b433557e419c5e70df3223badf3f100df6fcf03a2f79d18d1a9df126413f48ea.css.gz
```

You can interpret the above as:
* Our JS that was compiled by vite is 1.68 kB + 110.98 kB + 128.70 kB = 241.36 kB compressed
* Our CSS that was compiled by vite is 23.71 kB compressed
* Our JS that was compiled by sprockets is 79 kB compressed
* Our CSS that was compiled by sprockets is 49 kB compressed
