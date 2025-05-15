const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffprobePath = require('@ffprobe-installer/ffprobe').path;
const ffmpeg = require('fluent-ffmpeg');

ffmpeg.setFfmpegPath(ffmpegPath);
ffmpeg.setFfprobePath(ffprobePath);
const admin = require("firebase-admin");
const { Storage } = require("@google-cloud/storage");
const fs = require("fs");
const path = require("path");
const cliProgress = require("cli-progress");
//const ffmpeg = require("fluent-ffmpeg");
//const ffmpegPath = require("ffmpeg-static");

//ffmpeg.setFfmpegPath(ffmpegPath);

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "cowardly-app.firebasestorage.app", // ✅ Not "firebasestorage.app"
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

// Paths
const localVideoPath = "D:/Flutter Project/cowardly_app_automation/upload-read-encoded-videos/Dragon-tales-Kingdom-Come-output.mp4";
const localThumbPath = "./thumb.jpg";
const videoStoragePath = "videos/Dragon-tales-Kingdom-Come-output.mp4";
const thumbStoragePath = "cartoon-thumbnails/Dragon-tales-Kingdom-Come-output.jpg";

async function generateThumbnail(videoPath, thumbnailPath) {
  return new Promise((resolve, reject) => {
    ffmpeg(videoPath)
      .on("end", () => resolve())
      .on("error", (err) => reject(err))
      .screenshots({
        count: 1,
        filename: path.basename(thumbnailPath),
        folder: path.dirname(thumbnailPath),
        size: "1280x720",
      });
  });
}

async function uploadFile(localPath, storagePath, contentType) {
  const fileSize = fs.statSync(localPath).size;
  const fileRef = bucket.file(storagePath);

  const progressBar = new cliProgress.SingleBar({
    format: '📤 Upload |{bar}| {percentage}% | {value}/{total} bytes',
    barCompleteChar: '\u2588',
    barIncompleteChar: '\u2591',
    hideCursor: true,
  });

  progressBar.start(fileSize, 0);
  let uploaded = 0;

  const fileStream = fs.createReadStream(localPath);
  const writeStream = fileRef.createWriteStream({
    resumable: false,
    metadata: {
      contentType,
      cacheControl: "public,max-age=31536000",
    },
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
        resolve(`https://storage.googleapis.com/${bucket.name}/${fileRef.name}`);
      })
      .on("error", (err) => {
        progressBar.stop();
        reject(err);
      });
  });

  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${file.name}`;
}

async function uploadVideoAndThumbnail() {
  console.log("🎥 Generating thumbnail...");
  await generateThumbnail(localVideoPath, localThumbPath);

  console.log("📤 Uploading video...");
  const videoUrl = await uploadFile(localVideoPath, videoStoragePath, "video/mp4");

  console.log("🖼️ Uploading thumbnail...");
  const thumbnailUrl = await uploadFile(localThumbPath, thumbStoragePath, "image/jpeg");

  console.log("📝 Saving metadata to Firestore...");
  await db.collection("videos").add({
   title: "Dragon Tales Kingdom Come",
   description: "Ord becomes selfish and refuses to share anything with his friends during a beach party, especially a wishing shell he finds and he ends up wishing himself and then the rest of the gang to a kingdom with no way out, since a selfish dragon named Monsieur Marmadune also refuses to share the key to let them out of the kingdom and return to the beach party before it ends. Ord must learn to share something with the selfish dragon in order for him to let them borrow the key and continue the beach party.",
    category: "cartoon",
    show: "Dragon Tales",
    videoUrl,
    thumbnailUrl,
    videoLength: "12:46",
    languages: ["Hindi"],
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

//   await db.collection("videos").add({
//      title: "Courage the Fly",
//      description: "Di Lung is outside the Bagge Farm working on his giant magnet machine. Courage arrives and asks what's going on and Di Lung responds that he's going to make a satellite fall from the sky with the magnet. He then shows Courage his new transformation formula, saying it will make him different. Courage undergoes several mutations before eventually being turned into a fly. Di Lung remarks that Courage should have turned into a buffalo and leaves to fix the formula. Sure enough, Di Lung's magnet pulls a satellite from orbit and sends it hurtling towards the farmhouse. The General and Federal Agents take notice and head to the farm to investigate.",
//      category: "cartoon",
//      show: "Courage the Cowardly Dog",
//      videoUrl,
//      thumbnailUrl,
//      videoLength: "21:44",
//      languages: ["Hindi"],
//      createdAt: admin.firestore.FieldValue.serverTimestamp()
//    });

  console.log("✅ Upload complete!");
}

uploadVideoAndThumbnail().catch(console.error);
