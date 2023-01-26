#!/bin/bash
DEFAULT_OUTFILE="out"
OUTFILE=
# Parameter checks
if [[ -z $1 ]]; then
	echo "No Domain Parameter passed"
	exit 1
fi
if [[ -z $2 ]]; then
	echo "No outfile passed. Using default of $DEFAULT_OUTFILE"
	OUTFILE=$DEFAULT_OUTFILE
else
	OUTFILE=$2
fi

# Quick explanation on: ([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")
## $? is just checking the status of the last command. 0 is good. Anyting else is not.
## when we && that check if it's zero together with the SUCCESS, it only prints SUCCESS if it's 0.
## If it is not 0, it hits the || and prints FAILURE

# You can add additional variables and assign them that information for storing later.
# Better yet, you could grab a certain number of lines after a given search term with sed or awk
echo "Getting WHOIS INFO"
WHOIS_INFO=$(whois $1 | grep "Registra") # will grab lines with REGISTRANT and REGISTRAR
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

echo "Getting A Record"
# Grabbing first line after "ANSWER SECTION"
# https://stackoverflow.com/questions/7451423/how-to-show-only-next-line-after-the-matched-one
A_RECORD=$(dig $1 A | awk '/ANSWER SECTION/{getline; print}')
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")
echo "Getting MX Records"
# Grabbing MX records, grepping for MX and starting from 3rd line since first 2 are not part of the result
MX_RECORDS=$(dig $1 MX | grep "MX" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

# Doing the same thing for AAAA records as MX. You get the picture. I'll stop describing this pattern here.
echo "Getting AAAA Record"
AAAA_RECORD=$(dig $1 AAAA | grep "AAAA" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

echo "Getting SRV Record"
# I don't actually know what the response looks like for SRV records so this might not work as intended
SRV_RECORD=$(dig $1 SRV | grep "SRV" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

echo "Getting TXT Record"
TXT_RECORD=$(dig $1 TXT | grep "TXT" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

echo "Getting CNAME Record"
CNAME_RECORD=$(dig $1 CNAME | grep "CNAME" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")
# Also haven't been able to find a website that returns this (haven't dug much, you can find one I'm sure)

echo "Getting SPF Record"
SPF_RECORD=$(dig $1 SPF | grep "SPF" | tail -n +3)
([ "$?" == 0 ] && echo "SUCCESS" || echo "FAILURE")

if [ -f "$OUTFILE" ]; then
	echo "OVERWRITING OUTFILE"
	rm $OUTFILE
fi

echo "Writing to File"
# Note it's important to wrap variables with Double quotes when you expect there may be multiple lines.
# If you do not, it will treat them as one long string without newline characters.
echo "===WHOIS INFO===" >> $OUTFILE
echo "$WHOIS_INFO" >> $OUTFILE
echo "===A RECORD===" >> $OUTFILE
echo "$A_RECORD" >> $OUTFILE
echo "===MX RECORDS===" >> $OUTFILE
echo "$MX_RECORDS" >> $OUTFILE
echo "===AAAA RECORD===" >> $OUTFILE
echo "$AAAA_RECORD" >> $OUTFILE
echo "===SRV RECORD===" >> $OUTFILE
echo "$SRV_RECORD" >> $OUTFILE
echo "===TXT RECORD===" >> $OUTFILE
echo "$TXT_RECORD" >> $OUTFILE
echo "===CNAME RECORD===" >> $OUTFILE
echo "$CNAME_RECORD" >> $OUTFILE
echo "===SPF RECORD===" >> $OUTFILE
echo "$SPF_RECORD" >> $OUTFILE

echo "Done"
