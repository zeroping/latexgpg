# LatexGPG

This is a utility to generate paper backups of GPG keys, including ones with subkeys. These backups include hand-typeable hex, and a (huge) QR code.

## Sample Output
There are [sample PDF files](https://raw.githubusercontent.com/zeroping/latexgpg/master/samples/0x505046B10F254146.pdf) for a test key located in /samples. The test key they represent looks like this:
```
sec   rsa4096/0x505046B10F254146 2018-02-04 [SCEA]
      Key fingerprint = E15D A5E3 414D 83D6 CDDA  A578 5050 46B1 0F25 4146
uid                   [ultimate] test test (If this key leaves my local machine, I've screwed up. Please delete it from any listings) <test@test.test>
uid                   [ultimate] test test
ssb   rsa4096/0x3EA6EA6016656732 2018-02-04 [A] [expires: 2068-01-23]
ssb   rsa4096/0x9D3522052CC8DFAB 2018-02-04 [E] [expires: 2068-01-23]
ssb   rsa4096/0xAC2FFAAC06A43B6C 2018-02-04 [S] [expires: 2068-01-23]
```

Try recovering that key to see how it works.

## Prerequsites

This is designed to run under Linux, and needs the gpg utility, bash, and latex installed.

## Running

Run the generator by finding the fingerprint of the key you want to export, and calling it like this from the directory:

`cd latexgpg`

`./latexgpg <key-id>`

That is:
`./latexgpg 0x505046B10F254146` for my test keys


