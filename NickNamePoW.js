const crypto = require('crypto');

function sha256Hash(nickname, nonce) {
    const data = `${nickname}${nonce}`;
    return crypto.createHash('sha256').update(data, 'utf8').digest('hex');
}

function mine(nickname, targetZeros) {
    let nonce = 0;
    const startTime = Date.now();

    while (true) {
        const hashResult = sha256Hash(nickname, nonce);
        if (hashResult.startsWith('0'.repeat(targetZeros))) {
            const elapsedTime = (Date.now() - startTime) / 1000; // 转换为秒
            console.log(`Nonce: ${nonce}, Hash: ${hashResult}, Time for ${targetZeros} zeros: ${elapsedTime.toFixed(2)}s`);
            return elapsedTime;
        }
        nonce += 1;
    }
}

(async () => {
    const nickname = "Victor";  // 替换为你的昵称
    console.log("开始挖矿...");

    const timeFor4Zeros = mine(nickname, 4);
    const timeFor5Zeros = mine(nickname, 5);
    const timeForNZeros = mine(nickname, 6); // 可选，挖掘6个零的哈希
})();
