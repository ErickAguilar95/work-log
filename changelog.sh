#!/bin/bash

CHANGELOG_DIR="changelog"

MONTH_NAME=$(LC_ALL=C date +"%B")
MONTH_LOWER=$(echo "$MONTH_NAME" | tr '[:upper:]' '[:lower:]')
MONTH_NUM=$(LC_ALL=C date +"%m")
YEAR=$(LC_ALL=C date +"%Y")
DAY=$(LC_ALL=C date +"%d")
DATE_FMT="${DAY}-${MONTH_NUM}-${YEAR}"

FILENAME="${MONTH_LOWER}-${YEAR}.md"
FILEPATH="${CHANGELOG_DIR}/${FILENAME}"

mkdir -p "$CHANGELOG_DIR"

if [ ! -f "$FILEPATH" ]; then
    echo "# Changelog — ${MONTH_NAME} ${YEAR}" > "$FILEPATH"
    echo "Todas las modificaciones relevantes de este mes se documentan aquí." >> "$FILEPATH"
    echo "✓ Archivo creado: ${FILEPATH}"
fi

TITLE="Carga de componentes al frontend"
DESCRIPTIONS=()

trap 'stty sane 2>/dev/null; echo; exit 130' INT TERM

save_entry() {
    {
        echo ""
        echo "## [${DATE_FMT}] - ${TITLE}"
        for desc in "${DESCRIPTIONS[@]}"; do
            echo "- ${desc}"
        done
    } >> "$FILEPATH"
    echo ""
    echo "✓ Sección guardada en ${FILEPATH}"
}

show_menu() {
    clear
    echo "╔═════════════════════════════════════════╗"
    echo "║         ✏️  Changelog Entry              ║"
    echo "╠═════════════════════════════════════════╣"
    printf "║  Archivo: %-33s ║\n" "${FILEPATH}"
    printf "║  Fecha:   %-33s ║\n" "${DATE_FMT}"
    echo "╠═════════════════════════════════════════╣"
    printf "║  Titulo: %-32s ║\n" "${TITLE}"
    echo "║  Descripciones:"
    if [ ${#DESCRIPTIONS[@]} -eq 0 ]; then
        echo "║    (ninguna)"
    else
        for i in "${!DESCRIPTIONS[@]}"; do
            printf "║    %d. %-33s ║\n" $((i+1)) "${DESCRIPTIONS[$i]}"
        done
    fi
    echo "╠═════════════════════════════════════════╣"
    echo "║  Shortcuts:                             ║"
    echo "║    [t] Editar titulo                    ║"
    echo "║    [d] Agregar descripcion              ║"
    echo "║    [s] Guardar y salir                  ║"
    echo "║    [q] Salir sin guardar                ║"
    echo "╚═════════════════════════════════════════╝"
    echo ""
    printf "Presiona una tecla: "
}

while true; do
    show_menu
    read -n 1 -s key
    echo ""
    case "$key" in
        t|T)
            echo ""
            printf "Titulo actual: %s\n" "${TITLE}"
            printf "Nuevo titulo: "
            read -e input_title
            [ -n "$input_title" ] && TITLE="$input_title"
            ;;
        d|D)
            echo ""
            echo "Agrega descripciones (Enter vacio para terminar):"
            while true; do
                printf "  → "
                read -e desc
                [ -z "$desc" ] && break
                DESCRIPTIONS+=("$desc")
            done
            ;;
        s|S)
            if [ ${#DESCRIPTIONS[@]} -eq 0 ]; then
                echo ""
                printf "⚠ No hay descripciones. Guardar de todas formas? (s/N): "
                read -n 1 -s confirm
                echo ""
                [ "$confirm" != "s" ] && [ "$confirm" != "S" ] && continue
            fi
            save_entry
            break
            ;;
        q|Q)
            echo ""
            echo "Saliendo sin guardar."
            exit 0
            ;;
        *)
            echo ""
            echo "Opcion invalida: ${key}"
            sleep 0.8
            ;;
    esac
done

echo ""
printf "Subir cambios a git? (s/N): "
read -n 1 -s git_choice
echo ""
if [ "$git_choice" = "s" ] || [ "$git_choice" = "S" ]; then
    git add "$FILEPATH"
    git commit -m "changelog: ${TITLE} [${DATE_FMT}]"
    git push
    echo "✓ Cambios subidos a git"
fi

echo "✓ Listo."
