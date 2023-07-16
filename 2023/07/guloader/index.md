# Destroying GuLoader


## Situation

Placeholder

### Key Points
- Placeholder
- Placeholder
- Placeholder

Placeholder

## Infection Chain

### Malspam Email

The infection chain starts with an email purporting to be from Dr. S. Susan (PHD) University of Trento, a university recognized for its significant accomplishments in teaching, research. The email contains the attachment `Richiesta Preventivo: (ISGB) 7788EU - 0605ITA.pdf.zip`. The attached file has a double extension likely in an attempt of have the user open the file once downloaded (Figure placeholder).

![GuLoader Malspam](images/a7810c71deae0934508e2e0e6173720de3dc4af99b94ac73f799d641a5df4160.jpg)
*Figure placeholder. Malspam Email in Italian*

The Italian language used in the pretext is poor and was directly translated to English, showcasing the lack of knowledge in Italian (Figure placeholder).

```text
Good morning sir/madame

greetings from the university of Trento

we of trento university, would be happy to make business with you in future, but before, we want to attach you the products we are intrested in.

We would be grateful if you could give us the better price and answer us fast.
Your answer is very needed.

Thanks a lot.
```
*Figure placeholder. Email Translated to English (GenericSkid)*

### NullSoft Installer

Once the `Richiesta Preventivo: (ISGB) 7788EU - 0605ITA.pdf.zip` has been extracted, the NullSoft Installer `Richiesta Preventivo (ISGB) 7788EU - 0605ITA·pdf.exe` is extracted in the same directory. Next, the resulting executable file can be extracted using 7zip to obtain the NullSoft Installer script and contained files (Figure placeholder).

```text
b2d2f116713950b0742c2cb384c0377ac414be769d317f9e246ecb66730c889d/
├── $PLUGINSDIR
│   └── System.dll
├── Halmen
│   └── Muculent
│       └── Coracoradialis
│           └── Maskulin
│               ├── regentpar.lyn
│               └── salmerne.pia
├── slutchy.lob
├── Tyros
│   └── Nulrendes
│       └── Trofens153
│           └── Stauromedusan
│               ├── Ardilla.Fra
│               ├── Copart.moo
│               └── stte.Kvi
├── Velchanos235
│   └── Sproghistorie198
│       └── brevbrerne.amy
└── Ydergrnsernes
    └── Protodermal
        └── telsonic
            └── Paternalisme
                ├── spillefugles.sle
                └── vorlages.dds
```
*Figure Placeholder. Extracted NullSoft Installer Files*

### NullSoft Installer Script

Once executed, the NullSoft Installer write the file `%USERPROFILE%\gastrotrich\Tyros\Nulrendes\Trofens153\Stauromedusan\stte.Kvi` and obtains its handle. Next, the NullSoft Installer seeks in the file to the offset `41000`. Once completed, the NullSoft Installer reads one byte from the file then increments file pointer ahead by `414` bytes.

```python
def decode(file_path, offset, increment, delimiter):
    data = bytearray(open(file_path, 'rb').read())
    result = ''
    for i in range(offset, len(data), increment):
        if data[i] != ord(delimiter): result += chr(data[i])
        else: result += '\n'
    return '\n'.join([x for x in result.splitlines() if '::' in x])
```
*Figure placeholder. NullSoft Installer Decoding Algorithm for `stte.Kvi`*

```c
user32::ShowWindow(ir3,i0)
kernel32::CreateFileA(m r4 , i 0x80000000, i 0, p 0, i 4, i 0x80, i 0)i.r5
kernel32::SetFilePointer(i r5, i 963101 , i 0,i 0)i.r3
kernel32::VirtualAlloc(i 0,i 75603968, i 0x3000, i 0x40)p.r6
kernel32::ReadFile(i r5, i r6, i 75603968,*i 0, i 0)i.r3
user32::EnumWindows(i r6 ,i 0)
```
Figure placeholder. Decoded Output

## Indicators of Compromise

| Type   | Indicator                                                        | Description                                                                 |
| ------ | ---------------------------------------------------------------- | --------------------------------------------------------------------------- |
| SHA256 | f10f3adda4426ff71c0fbcb9f3ccdd0d46733e3661921d0048435bc9788c93f0 | Initial Malspam ZIP                                                         |
| SHA256 | b2d2f116713950b0742c2cb384c0377ac414be769d317f9e246ecb66730c889d | NullSoft Installer (`Richiesta Preventivo (ISGB) 7788EU - 0605ITA·pdf.exe`) |
| SHA256 | 83efb1c950c2af84ba48b9621f9f66dc097bfb73fc0dad13c55f63ee4c8797a9 | NullSoft Installer Icon                                                     |
| SHA256 | a632d74332b3f08f834c732a103dafeb09a540823a2217ca7f49159755e8f1d7 | System.dll (Legit NullSoft Plugin)                                          |
| SHA256 | f0846139e76fe25254efed718dc9b547ebafd020bffce0d1c2311ec417a4a073 | NSIS Script                                                                 |
| SHA256 | a6f2e76f42072921eb65888d0b333f216928319be26bea6498d2be1cd495a1c7 | NullSoft Installer Encoded Shellcode (stte.Kvi)                             | 

## Mitre Attack TTPs

| ID          | Tactic      | Technique   | Description |
| ----------- | ----------- | ----------- | ----------- |
| Placeholder | placeholder | placeholder | placeholder            |

## References
- https://app.any.run/tasks/e34cec9f-59cc-4ffe-845c-15b8357c3676/
- https://bazaar.abuse.ch/sample/f10f3adda4426ff71c0fbcb9f3ccdd0d46733e3661921d0048435bc9788c93f0/
- https://twitter.com/JAMESWT_MHT/status/1678703395991961605
- https://nsis.sourceforge.io/Reference/

# Contributors
- [whichbuffer](https://twitter.com/WhichbufferArda)
- irfaneternal
- GenericSkid
