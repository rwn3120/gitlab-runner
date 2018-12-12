#!/bin/bash -eu
function inf() { echo -e "\\e[97m${*}\\e[39m"; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

function generateName() {
    ADJECTIVES=(attractive bald beautiful chubby clean dazzling drab elegant fancy fit flabby glamorous gorgeous handsome long magnificent muscular plain plump quaint scruffy shapely short skinny stocky ugly unkempt unsightly ashy black blue gray green icy lemon mango orange purple red salmon white yellow alive better careful clever dead easy famous gifted hallowed helpful important inexpensive mealy mushy odd poor powerful rich shy tender unimportant uninterested vast wrong aggressive agreeable ambitious brave calm delightful eager faithful gentle happy jolly kind lively nice obedient polite proud silly thankful victorious witty wonderful zealous angry bewildered clumsy defeated embarrassed fierce grumpy helpless itchy jealous lazy mysterious nervous obnoxious panicky pitiful repulsive scary thoughtless uptight worried broad chubby crooked curved deep flat high hollow low narrow refined round shallow skinny square steep straight wide big colossal fat gigantic great huge immense large little mammoth massive microscopic miniature petite puny scrawny short small tall teeny tiny)
    ANIMALS=(aardvark aardwolf albatross albertosaurus allosaurus alligator alpaca anaconda angelfish anglerfish ankylosaurus ant anteater antelope antlion apatosaurus argentinosaurus armadillo asp axolotl baboon badger bandicoot barnacle barracuda basilisk bass bat bear beaver bedbug bee beetle beluga bison blackbird bluebird boa boar bobcat bobolink bonobo booby bovid buffalo bug brachiosaurus bull butterfly buzzard camel camptosaurus canid capybara cardinal caribou carnotaurus carp cat catshark caterpillar catfish cattle centipede ceratosaurus chameleon cheetah chickadee chicken chimpanzee chinchilla chipmunk coati cicada clam clownfish cobra cockroach cod condor constrictor coral corythosaurus cougar cow coyote coypu crab crane crayfish cricket crocodile crow cuckoo damselfly deer dhole dingo dinosaur dodo dog dolphin donkey dormouse dove dragonfly dragon dromaeosaurus duck eagle earthworm earwig echidna edmontonia edmontosaurus eel egret elephant elk emu ermine euoplocephalus falcon ferret finch firefly fish flamingo flea fly fowl fox frog gamefowl galliform gallimimus gazelle gecko gerbil gibbon giraffe goat goldfish goose gopher gorilla grasshopper grebe grouse guan guanaco guineafowl gull guppy haddock hadrosaurus halibut hamster hare harrier hawk hedgehog heron herring hippopotamus hookworm hornet horse hoverfly human hummingbird hyena hyrax iguana iguanadon ibis jackal jacana jaguar jay jellyfish kangaroo kentrosaurus kingfisher kite kiwi koi krill ladybug lamprey lambeosaurus landfowl lapwing lark leech lemming lemur leopard leopon limpet lion lionfish lizard llama lobster locust loon loris louse lungfish lynx macaw mackerel magpie mallard manatee mandrill marlin marmoset marmot marten mastodon maya meadowlark meerkat mink minnow mite mockingbird mole mollusk mongoose monkey moose mosquito moth mouse mule muskox narwhale needlefish newt nighthawk nightingale numbat ocelot octopus okapi olingo opossum orangutan orca oribi orinithomimus ostrich otter oviraptor owl ox pacycephalosaurus panther parakeet parasaurolophus parrot parrotfish partridge peacock peafowl pelican penguin perch pheasant pig pigeon pike piranha planarian plateosaurus platypus pony porcupine porpoise possum prawn ptarmigan puffin puma python quail queleal quetzal quetzalcoatlus quokka rabbit raccoon rat rattlesnake raven ray reindeer rhinoceros roadrunner rook rooster roundworm sailfish salamander salmon sawfish scallop scorpion seahorse serval shark sheep shrew shrimp silkworm silverfish skate skink skunk sloth slug smelt snail snake snipe sole sparrow spider spinosaurus spoonbill squid squirrel starfish stegosaurus stingray stoat stork sturgeon struthiomimus styracosaurus suchomimus swallow swan swift swordfish swordtail tahr takin tapir tarantula tarsier termite tern terrapin thrush tick tiger tiglon titi toad tortoise toucan triceratops trout tuna turkey turtle urial unicorn uakari vaquita velociraptor vicuna viper vixen vole vulture wallaby walrus wasp warbler waterbuck weasel whale whippet whitefish wildcat wildebeest wildfowl wolf wolverine wombat woodchuck woodpecker worm wren yak yapok zebra zebu zorilla)

    ADJECTIVE=${ADJECTIVES[$RANDOM % ${#ADJECTIVES[@]}]}
    ANIMAL=${ANIMALS[$RANDOM % ${#ANIMALS[@]}]}
    echo "${ADJECTIVE}-${ANIMAL}"
}

IMAGE="radowan/gitlab-runner"

ARGS=("${@}")

for i in "${!ARGS[@]}"; do
    if [ "${ARGS[${i}]}" == "-h" ] || [ "${ARGS[${i}]}" == "-?" ] || [ "${ARGS[${i}]}" == "--help" ]; then
        docker run "${IMAGE}" runner -h | sed "s/Usage:.*/Usage: ${SCRIPT_NAME} [OPTIONS]/"
        exit 1
    fi
    if [ "${ARGS[${i}]}" == "-N" ]; then
        CONTAINER_NAME="${ARGS[$((i+1))]}"
    fi
done
export NAME="${NAME:-${CONTAINER_NAME:-$(generateName)}}"

if [ "${INTERACTIVE:-"false"}" == "true" ]; then
    RUNNING_MODE="-it"
else
    RUNNING_MODE="-dt"
fi

inf "Starting container ${NAME}"
docker pull "${IMAGE}"
docker run \
    ${RUNNING_MODE} \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "${HOME}/.docker:/root/.docker" \
    --name "${NAME}" \
    --hostname "${NAME}" \
    --restart "on-failure:${RESTART_LIMIT:-2}" \
    "${IMAGE}" \
        runner "${@}"

timeout "${TIMEOUT:-"5s"}" docker logs -f "${NAME}"
docker ps -q --filter "name=${NAME}"
