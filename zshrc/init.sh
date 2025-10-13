INITS=$(fd -e sh . ~/zshrc/init)

FILES=($(echo $INITS | tr '\n' ' '))

for FILE in $FILES; do
    source $FILE
done
