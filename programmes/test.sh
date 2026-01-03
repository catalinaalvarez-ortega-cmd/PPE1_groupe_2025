if [[ ! -d "./aspirations/$lang" && ! -d "./dumps-text/$lang" && ! -d "./contextes/$lang" && ! -d "./concordances/$lang" ]] && ! -d "./aspirations/$lang" && ! -d "./dumps-text/$lang" && ! -d "./contextes/$lang" && ! -d "./concordances/$lang" ]]; then
        mkdir "./aspirations/$lang";
        mkdir "./dumps-text/$lang";
        mkdir "./contextes/$lang";
        mkdir "./concordances/$lang";
else 
    echo "Les dossiers existent déjà.";
fi

# tester l'existance d'un fichier 
if [ -f "./contextes/espagnol/espagnol-50.txt" ]; then echo "Le fichier existe"; fi