if [ -z "$1" ]
then
  echo "Please supply a subdomain to create a certificate for";
  echo "e.g. www.mysite.com"
  exit;
fi

DOMAIN=$1
COMMON_NAME=${2:-*.$1}
SUBJECT="/C=BE/ST=Vlaams-Brabant/L=Leuven/O=Zenjoy/OU=IT Department/CN=$COMMON_NAME"
# Starting on September 1st (2020), SSL/TLS certificates cannot be issued for longer than 13 months (397 days).
# https://stackoverflow.com/a/65239775
NUM_OF_DAYS=396
openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout device.key -subj "$SUBJECT" -out device.csr
cat ~/.dotfiles/ssl/v3.ext | sed s/%%DOMAIN%%/$COMMON_NAME/g > /tmp/__v3.ext
openssl x509 -req -in device.csr -CA ~/.ssl/rootCA.pem -CAkey ~/.ssl/rootCA.key -CAcreateserial -out device.crt -days $NUM_OF_DAYS -sha256 -extfile /tmp/__v3.ext 

# move output files to final filenames
mv device.key $DOMAIN.key
mv device.csr $DOMAIN.csr
cp device.crt $DOMAIN.crt

# remove temp file
rm -f device.crt;

echo 
echo "###########################################################################"
echo Done! 
echo "###########################################################################"
echo "To use these files on your server, simply copy both $DOMAIN.csr and"
echo "device.key to your webserver, and use like so (if Apache, for example)"
echo 
echo "    SSLCertificateFile    /path_to_your_files/$DOMAIN.crt"
echo "    SSLCertificateKeyFile /path_to_your_files/device.key"

