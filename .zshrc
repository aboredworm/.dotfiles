source ~/zshrc/init.sh 

CONFIGS=$(fd -E init -e sh . ~/zshrc)
FILES=($(echo $CONFIGS | tr '\n' ' '))

for FILE in $FILES; do
    source $FILE
done
