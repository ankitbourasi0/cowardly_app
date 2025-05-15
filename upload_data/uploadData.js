const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const cartoons = [
  {
    title: "Tom and Jerry",
    description: "Classic slapstick cartoon featuring a cat and a mouse in endless rivalry.",
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2Ftom-and-jerry.jpg?alt=media&token=9d3ebf8b-aae3-4df0-be1b-430967eff8bd",
  },
  {
    title: "SpongeBob SquarePants",
    description: "Underwater comedy about SpongeBob and his quirky friends in Bikini Bottom.",
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2Fspongbob.jpg?alt=media&token=2af66b5c-7eed-4986-9dd9-5b7bd0651c1d",
  },
  {
    title: "Doraemon",
    description: "A robot cat from the future helps Nobita using futuristic gadgets.",
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2FDoraemon.jpg?alt=media&token=c2367dd0-9919-4023-9764-dedfa8d00962",
  },
  {
    title: "Courage the Cowardly Dog",
    description: "A timid dog faces supernatural forces to protect his owners.",
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2FCourage.jpg?alt=media&token=38f341c4-c92d-4470-85ee-5d3577763757",
  },
  {
    title: "Ben 10",
    description: "A boy finds a watch that allows him to transform into powerful aliens.",
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2Fben-10.jpg?alt=media&token=12151eb5-1167-472f-8dd1-952ba966c04b",
  },
];


async function uploadCartoons() {
  const cartoonCollection = db.collection("cartoon");

  for (const cartoon of cartoons) {
    await cartoonCollection.add({
      ...cartoon,
      videoUrl: "",
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log(`✅ Uploaded: ${cartoon.title}`);
  }

  console.log("🎉 All cartoons uploaded successfully!");
}
//async function uploadCartoons() {
//  const cartoonRef = db.collection("category").collection("cartoon");
//  for (const cartoon of cartoons) {
//    await cartoonRef.add({
//      ...cartoon,
//      createdAt: admin.firestore.FieldValue.serverTimestamp(),
//      videoUrl: ""
//    });
//    console.log(`✅ Uploaded: ${cartoon.title}`);
//  }
//}

uploadCartoons();
