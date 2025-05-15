const admin = require("firebase-admin");
const { Storage } = require("@google-cloud/storage");
const fs = require("fs");
const path = require("path");
const cliProgress = require("cli-progress");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "cowardly-app.firebasestorage.app", // ✅ your bucket here
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

const localFilePath = "./ctcd-s2e2.mp4";
const firebaseStoragePath = "videos/s2e2-output.mp4";

//upload videos with meta deta without progress bar
//async function uploadToStorage() {
//  console.log("🚀 Uploading to Firebase Storage...");
//
//  const [file] = await bucket.upload(localFilePath, {
//    destination: firebaseStoragePath,
//    resumable: false,
//    metadata: {
//      contentType: "video/mp4",
//      cacheControl: "public,max-age=31536000",
//    },
//  });
//
//  // Make public OR generate download URL
//  await file.makePublic();
//  const publicUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
//  console.log("✅ Uploaded video URL:", publicUrl);
//  return publicUrl;
//}

//upload videos with meta deta with showing progress bar

async function uploadToStorage() {
  console.log("🚀 Uploading to Firebase Storage with progress...");

  const fileSize = fs.statSync(localFilePath).size;
  const fileName = path.basename(localFilePath);
  const destination = firebaseStoragePath;

  const fileRef = bucket.file(destination);

  const progressBar = new cliProgress.SingleBar({
    format: '📤 Upload Progress |{bar}| {percentage}% | {value}/{total} bytes',
    barCompleteChar: '\u2588',
    barIncompleteChar: '\u2591',
    hideCursor: true
  });

  progressBar.start(fileSize, 0);

  let uploaded = 0;
  const fileStream = fs.createReadStream(localFilePath);
  const writeStream = fileRef.createWriteStream({
    resumable: false,
    contentType: 'video/mp4',
    metadata: {
      cacheControl: 'public,max-age=31536000',
    }
  });

  fileStream.on("data", (chunk) => {
    uploaded += chunk.length;
    progressBar.update(uploaded);
  });

  return new Promise((resolve, reject) => {
    fileStream.pipe(writeStream)
      .on("finish", async () => {
        progressBar.stop();
        await fileRef.makePublic();
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileRef.name}`;
        console.log("✅ Upload complete. URL:", publicUrl);
        resolve(publicUrl);
      })
      .on("error", (err) => {
        progressBar.stop();
        reject(err);
      });
  });
}

async function uploadToFirestore(videoUrl) {
  console.log("📝 Uploading metadata to Firestore...");

  const videoData = {
    title: "The Curse of Shirley",
    description: "Muriel orders a new bed that turns out to be possessed!",
    category: "cartoon",
    show: "Courage the Cowardly Dog",
    videoUrl: videoUrl,
    thumbnailUrl: "https://firebasestorage.googleapis.com/v0/b/cowardly-app.firebasestorage.app/o/cartoon-thumbnails%2FCourage.jpg?alt=media&token=38f341c4-c92d-4470-85ee-5d3577763757", // adjust as needed
    videoLength: "20:33",
    languages: ["Hindi", "Tamil", "Telugu", "English"],
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  };

  const docRef = await db.collection("videos").add(videoData);
  console.log(`✅ Firestore doc created with ID: ${docRef.id}`);
}

async function main() {
  if (!fs.existsSync(localFilePath)) {
    console.error("❌ File not found:", localFilePath);
    return;
  }

  try {
    const videoUrl = await uploadToStorage();
    await uploadToFirestore(videoUrl);
    console.log("🎉 Upload complete!");
  } catch (err) {
    console.error("❌ Upload failed:", err);
  }
}

main();
