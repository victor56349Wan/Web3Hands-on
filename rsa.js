const crypto = require('crypto');

// 生成 RSA 公私钥对
function generateKeys() {
    const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048, // 指定密钥长度
    });
    return { publicKey, privateKey };
}

// 使用私钥签名
function signMessage(privateKey, message) {
    const sign = crypto.createSign('SHA256');
    sign.update(message);
    sign.end();
    return sign.sign(privateKey, 'base64');
}

// 使用公钥验证签名
function verifySignature(publicKey, message, signature) {
    const verify = crypto.createVerify('SHA256');
    verify.update(message);
    verify.end();
    return verify.verify(publicKey, signature, 'base64');
}

// 主程序
(async () => {
    const nickname = "Victor"; // 替换为你的昵称
    const nonce = crypto.randomBytes(16).toString('hex'); // 生成随机的nonce
    const message = `${nickname}${nonce}`; // 创建待签名的消息

    console.log("msg+nonce: ", message)
    // 生成公私钥对
    const { publicKey, privateKey } = generateKeys();

    // 用私钥签名
    const signature = signMessage(privateKey, message);
    console.log("签名生成成功！");

    // 用公钥验证签名
    const isValid = verifySignature(publicKey, message, signature);
    
    if (isValid) {
        console.log("签名验证成功！");
    } else {
        console.log("签名验证失败！");
    }

    // 打印 PEM 格式的密钥
    console.log("\nPrivate Key:\n", privateKey.export({ type: 'pkcs1', format: 'pem' }));
    console.log("Public Key:\n", publicKey.export({ type: 'spki', format: 'pem' }));
})();
