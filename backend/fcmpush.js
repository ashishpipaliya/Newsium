var admin = require('firebase-admin');
var serviceAccount = require('./utils/service-account.json');
const Token = require('./model/token_model')
require('dotenv').config()

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://flutter-fire-news.firebaseio.com'
});

const getTokensFromMongodb = async () => {
    try {
        const tokensData = await Token.find({});
        const tokens = tokensData.map(t => t.token);
        console.log(tokens);
        return tokens;
    } catch (e) {
        return [];
    }
}

const getNotificationPayload = async () => {
    try {
        const querySnapshot = await admin.firestore().collection('inshorts').orderBy('created_at', 'desc').limit(1).get();
        const notification = {
            body: querySnapshot.docs[0].data().title,
            image: querySnapshot.docs[0].data().image_url,
            android_channel_id : 'newsium',
        }
        const data = {
            category: querySnapshot.docs[0].data().category,
            created_at: querySnapshot.docs[0].data().created_at.toString(),
            click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
        var payload = {
            notification: notification,
            data: data
        };
        return payload;
    } catch (e) {
        return {};
    }
}

var options = {
    priority: "high"
};

const sendPush = () => {
    const hours = new Date().getHours();
    const sendNotifications = hours >= 6 && hours <= 22

    console.log(`send notifications = ${sendNotifications}`);

    if (sendNotifications) {
        getTokensFromMongodb().then(async (tokens) => {
            const payload = await getNotificationPayload();
            admin.messaging().sendToDevice(tokens, payload, options)
                .then(function (response) {
                    console.log("Successfully sent message:", response);
                })
                .catch(function (error) {
                    console.log("Error sending message:", error);
                });
        });
    }

}

// const getTokens = async () => {
//     try {
//         const querySnapshot = await firestore
//             .collection('tokens').get();
//         const tokens = querySnapshot.docs.map(snap => snap.data().token);
//         return tokens;
//     } catch (e) {
//         return [];
//     }
// }
// const sendPush = () => {
//     const hours = new Date().getHours();
//     const sendNotifications = hours > 6 && hours < 20

//     console.log(hours);
//     console.log(sendNotifications);

// if (sendNotifications) {
//         getTokens().then(async (tokens) => {
//             const payload = await getNotificationPayload();
//             admin.messaging().sendToDevice(tokens, payload, options)
//                 .then(function (response) {
//                     console.log("Successfully sent message:", response);
//                 })
//                 .catch(function (error) {
//                     console.log("Error sending message:", error);
//                 });
//         });
//     }

// }

module.exports = sendPush;


