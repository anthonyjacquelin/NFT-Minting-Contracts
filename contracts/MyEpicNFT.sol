pragma solidity ^0.8.1;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] firstWords = ["DAMSO", "BOOBA", "PNL", "JUL", "MAHES", "FHIN"];

    string[] secondWords = [
        "FEATURING",
        "VS",
        "SIGNE",
        "RENVOIE",
        "DONNES DE LA FORCE A"
    ];

    string[] thirdWords = [
        "DRAKE",
        "XXXTENTACION",
        "LIL TEKKA",
        "KATY PERRY",
        "RIHANNA"
    ];

    string[] colors = ["red", "blue", "green", "purple", "yellow", "orange"];

    // get random color from colors array
    function getRandomColor() public view returns (string memory) {
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        ) % colors.length;

        return colors[randomIndex];
    }

    string rand_color = getRandomColor();
    string baseSvg =
        string(
            abi.encodePacked(
                "<svg width='800' height='600' xmlns='http://www.w3.org/2000/svg'><g><rect fill='",
                rand_color,
                "' stroke='#000' x='-13' y='-0.5' width='815' height='603' id='svg_1'/><text fill='#000000' stroke='#000' stroke-width='0' x='384' y='372.5' id='svg_2' font-size='24' font-family='Noto Sans JP' text-anchor='start' xml:space='preserve'>"
            )
        );

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Woah!");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getNbTokensMinted() public view returns (uint256) {
        return _tokenIds.current();
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();
        console.log("baseSvg");
        console.log(baseSvg);

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, " ", second, " ", third)
        );
        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(
                baseSvg,
                newItemId,
                "</text><text fill='#000000' stroke='#000' stroke-width='0' x='311' y='257.5' id='svg_3' font-size='24' font-family='Noto Sans JP' text-anchor='start' xml:space='preserve'>",
                first,
                " ",
                second,
                " ",
                third,
                "</text></g></svg>"
            )
        );
        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
