#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
***************************************************
* Convert from multiline string into single line
* By: Nicola Ferralis <feranick@hotmail.com>
* version v2026.11.17.1
***************************************************
'''
#print(__doc__)

import sys, os.path, getopt

def main():

    saveInText = True

    try:
        opts, args = getopt.getopt(sys.argv[1:],
            "t:f:sph", ["text=", "file=", "stdin", "pipe", "help"])
    except getopt.GetoptError as err:
        print(" Error:", err, file=sys.stderr)
        usage()
        return 2

    if not opts:
        usage()
        return 0

    # Pipe mode: only the single-line result goes to stdout, nothing else
    pipe = any(o in ("-p", "--pipe") for o, _ in opts)

    for o, a in opts:
        if o in ("-h" , "--help"):
            usage()
            return 0

        if o in ("-t" , "--text"):
            print(toSingleLine(a))

        if o in ("-s" , "--stdin"):
            print(toSingleLine(sys.stdin.read()))

        if o in ("-f" , "--file"):
            file = a
            fileRoot = os.path.splitext(file)[0]
            outfile = fileRoot+"_single.txt"

            with open(file, 'r') as f:
                log(" Opening text file with multiple lines: "+file+"\n", pipe)
                data = toSingleLine(f.read())

            log(" Single line string: \n", pipe)
            print(data)
            log("", pipe)

            if saveInText and not pipe:
                with open(outfile, "w") as of:
                    of.write(data)
                log(" Single line text file saved in: "+outfile+"\n", pipe)

    return 0

def toSingleLine(text):
    return text.replace('\r', '').replace('\n', '')

def log(msg, quiet):
    # Status messages go to stderr so they never pollute a pipe
    if not quiet:
        print(msg, file=sys.stderr)

def usage():
    print(__doc__)
    print(' Usage:\n  python3 Multi2SingleLine.py -t \"<multi-line text>\"')
    print('  python3 Multi2SingleLine.py -f <file>')
    print('  python3 Multi2SingleLine.py -s              (read from stdin)')
    print('  python3 Multi2SingleLine.py -h\n')
    print(' Add -p (--pipe) to print only the result, e.g.:')
    print('  python3 Multi2SingleLine.py -p -f <file> | pbcopy')
    print('  cat <file> | python3 Multi2SingleLine.py -p -s | wc -c\n')

#************************************
''' Main initialization routine '''
#************************************
if __name__ == "__main__":
    sys.exit(main())
