//const admin = require("firebase-admin");
//const serviceAccount = require("./serviceAccountKey.json");
//
//admin.initializeApp({
//  credential: admin.credential.cert(serviceAccount),
//});
//
//const db = admin.firestore();
//
//const videos = [
//  {
//    title: "Doraemon: Time Machine Trouble",
//    description: "Nobita causes chaos with Doraemon’s time machine.",
//    category: "cartoon",
//    show: "Doraemon",
//    videoUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/videos%2F2.mp4?alt=media&token=xxx",
//    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/thumbnails%2Fdoraemon.jpg?alt=media",
//    videoLength: "6:45",
//    languages: ["English", "Hindi"]
//  },
//  {
//    title: "Ben 10: Vilgax Returns",
//    description: "Ben uses the Omnitrix to fight Vilgax again.",
//    category: "cartoon",
//    show: "Ben 10",
//    videoUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/videos%2Fben10.mp4?alt=media&token=xxx",
//    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/thumbnails%2Fben10.jpg?alt=media",
//    videoLength: "8:20",
//    languages: ["English"]
//  },
//  {
//    title: "Shinchan: Toy Store Mayhem",
//    description: "Shinchan creates chaos in a toy store.",
//    category: "cartoon",
//    show: "Shinchan",
//    videoUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/videos%2Fshinchan.mp4?alt=media&token=xxx",
//    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/thumbnails%2Fshinchan.jpg?alt=media",
//    videoLength: "7:10",
//    languages: ["Japanese", "Hindi"]
//  },
//
//];
//
//async function uploadVideos() {
//  const collectionRef = db.collection("videos");
//
//  for (const video of videos) {
//    await collectionRef.add({
//      ...video,
//      createdAt: admin.firestore.FieldValue.serverTimestamp()
//    });
//    console.log(`✅ Uploaded: ${video.title}`);
//  }
//
//  console.log("🎉 All videos uploaded successfully!");
//}
//
//uploadVideos().catch(console.error);
