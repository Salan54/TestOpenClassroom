#! /usr/bin/env python
# coding: utf-8

import fnmatch
import sys
import os
import time
import random
from subprocess import call
import argparse
import signal

def signal_handler(signal, frame):
        print
        print('Resetting WP')
        resetWP()

def walklevel(some_dir, level=1):
    some_dir = some_dir.rstrip(os.path.sep)
    assert os.path.isdir(some_dir)
    num_sep = some_dir.count(os.path.sep)
    for root, dirs, files in os.walk(some_dir):
        yield root, dirs, files
        num_sep_this = root.count(os.path.sep)
        if num_sep + level <= num_sep_this:
            del dirs[:]

def resetWP():
    f = open(os.path.expanduser('~/.bgrc'))
    line = f.readline()
    line = line.strip()
    os.system(line)
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

parser = argparse.ArgumentParser(description="Modification du fond d'écran à partir des images d'un répertoire.")
parser.add_argument("-p","--profondeur", type=int, help="Nombre de niveaux de sous-répertoires à explorer  (Défaut : juste le répertoire de base)", default='0')
lwd = os.getcwd()
parser.add_argument("directory", nargs='?', type=str, help="Répertoire à explorer (Défaut : répertoire courant)", default= lwd )
parser.add_argument("-d","--delay", type=int, help="Délai, en secondes, avant changement du fond d'écran (Défaut 60)", default='60')
parser.add_argument("-v","--verbosity", help="Affichage détaillé ou pas. (Défaut : non détaillé)", action="store_true" )
parser.add_argument("-t","--timeout", type=int, help="Durée d\'activité du programme, en secondes (Défaut : infini)", default='0')
parser.add_argument("--debug", help="Mode debug actif : pas de changement du WP mais listing, verbeux et délai=5s . (Défaut : mode normal)", action="store_true" )

args=parser.parse_args()

lwd = args.directory
profondeur = args.profondeur
delai = args.delay
verbosity = args.verbosity
debug = args.debug
if debug:
    verbosity = True
    delai = 5
timeout = args.timeout

if verbosity:
    print('Répertoire de travail  : %s' % lwd)
    print('Délai d\'affichage      : %d' % delai)
    if timeout == 0:
        print('Durée du programme     : infinie')
    else:
        print('Durée du programme     : %d' % timeout)
    print('Nombre de niveaux      : %d' % profondeur)

matches=[]
#for root,dirnames,filenames in os.walk(lwd):
for root,dirnames,filenames in walklevel(lwd,profondeur):
    for extension in ('*.jp*','*.gif','*.png'):
        for filename in fnmatch.filter(filenames,extension):
            matches.append(os.path.join(root,filename))
total = len(matches)
displayed=[]

if timeout == 0:
    nbimages = total
else:
    nbimages = int(timeout / delai)
if (nbimages == 0):
    nbimages = 1
elif nbimages > total:
    nbimages = total

if verbosity:
    print('Nb.elements à afficher : %d/%d' % (nbimages,total))
    print

compteur = 0
while True:
    rnd = random.randrange(0,len(matches))
    if (rnd in displayed):
        #print('%d déjà affiché.' % rnd)
        if (len(displayed) == len(matches)):
            #print('Plus rien à afficher.')
            break
    elif (compteur >= nbimages):
        break
    else:
        compteur +=1
        filename = matches[rnd]
        displayed.append(rnd)
        if verbosity:
            print('%d (%d/%d): %s' % (rnd,compteur,nbimages,filename))
        if debug:
            call(["ls","-lh",filename])
        else:
            call(["feh","--bg-max",filename])
        time.sleep(delai)

resetWP()

