function next-freshinstall() {
    echo "rm -rf node_modules/"
    rm -rf node_modules/

    echo "rm -rf .next/"
    rm -rf .next/

    echo "yarn install"
    yarn
}

function next-check() {
	echo "yarn lint : ESLint checks"
	yarn lint
    read -p "Poursuivre ? (Hint: Ctl-C to interrupt)"

    echo "yarn tsc - TypeScript checks"
    yarn tsc
    read -p "Poursuivre ? (Hint: Ctl-C to interrupt)"

    echo "yarn test - Run app tests"
    yarn test
    read -p "Poursuivre ? (Hint: Ctl-C to interrupt)"

    echo "yarn build - Build Next.js app"
    yarn build
    read -p "Poursuivre ? (Hint: Ctl-C to interrupt)"

    echo "yarn start - Start Next.js app"
    yarn start
    read -p "Poursuivre ? (Hint: Ctl-C to interrupt)"

}

# clean & run next project
function cleanrun() {
    echo "rm -rf node_modules/"
    rm -rf node_modules/
    echo "rm -rf .next/"
    rm -rf .next/
    echo "yarn install"
    yarn
    echo "yarn build"
    yarn build
    echo "yarn start"
    yarn start
}
