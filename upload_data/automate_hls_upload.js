
const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffprobePath = require('@ffprobe-installer/ffprobe').path;
const ffmpeg = require('fluent-ffmpeg');
const admin = require("firebase-admin");
const { Storage } = require("@google-cloud/storage");
const fs = require("fs");
const path = require("path");

ffmpeg.setFfmpegPath(ffmpegPath);
ffmpeg.setFfprobePath(ffprobePath);

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "cowardly-app.firebasestorage.app",
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

const localVideoPath = "D:/Flutter Project/cowardly_app_automation/upload-read-encoded-videos/Dragon-tales - Kingdom Come.mp4";
const localThumbPath = "./thumb.jpg";
const videoId = path.basename(localVideoPath).replace(/\.[^.]+$/, "");
const hlsOutputDir = `./hls/${videoId}`;
const hlsStoragePath = `videos/hls/${videoId}`;
const thumbStoragePath = `cartoon-thumbnails/${videoId}.jpg`;
const getVideoDuration = (filePath) =>
  new Promise((resolve, reject) => {
    ffmpeg.ffprobe(filePath, (err, metadata) => {
      if (err) return reject(err);
      const durationSeconds = metadata.format.duration || 0;
      const minutes = Math.floor(durationSeconds / 60);
      const seconds = Math.floor(durationSeconds % 60);
      resolve(`${minutes}:${seconds.toString().padStart(2, '0')}`);
    });
  });


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

async function convertToHLS(inputPath, outputDir) {
  return new Promise((resolve, reject) => {
    fs.mkdirSync(outputDir, { recursive: true });
    ffmpeg(inputPath)
      .outputOptions([
        "-codec: copy",
        "-start_number 0",
        "-hls_time 10",
        "-hls_list_size 0",
        "-f hls",
      ])
      .output(path.join(outputDir, "index.m3u8"))
      .on("end", resolve)
      .on("error", reject)
      .run();
  });
}

async function uploadFolderToStorage(localFolder, storageFolder) {
  const files = fs.readdirSync(localFolder);
  for (const fileName of files) {
    const localFilePath = path.join(localFolder, fileName);
    const storagePath = `${storageFolder}/${fileName}`;
    const fileRef = bucket.file(storagePath);
    await bucket.upload(localFilePath, {
      destination: storagePath,
      metadata: {
        contentType: fileName.endsWith(".m3u8") ? "application/x-mpegURL" : "video/MP2T",
        cacheControl: "public,max-age=31536000",
      },
    });
    await fileRef.makePublic();
  }
  return `https://storage.googleapis.com/${bucket.name}/${storageFolder}/index.m3u8`;
}

async function uploadFile(localPath, storagePath, contentType) {
  const fileRef = bucket.file(storagePath);
  await bucket.upload(localPath, {
    destination: storagePath,
    metadata: {
      contentType,
      cacheControl: "public,max-age=31536000",
    },
  });
  await fileRef.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
}

async function run() {
  console.log("🎥 Generating thumbnail...");
  await generateThumbnail(localVideoPath, localThumbPath);

  console.log("🔄 Converting to HLS...");
  await convertToHLS(localVideoPath, hlsOutputDir);

  console.log("📤 Uploading HLS files...");
  const videoUrl = await uploadFolderToStorage(hlsOutputDir, hlsStoragePath);

  console.log("🖼️ Uploading thumbnail...");
  const thumbnailUrl = await uploadFile(localThumbPath, thumbStoragePath, "image/jpeg");

// Later in your uploadVideoAndThumbnail
const duration = await getVideoDuration(localVideoPath);
  console.log("📝 Saving metadata to Firestore...");
  await db.collection("videos").add({
    title: "Dragon-tales - Kingdom Come",
    description: "Summary Ord becomes selfish and refuses to share anything with his friends during a beach party, especially a wishing shell he finds and he ends up wishing himself and then the rest of the gang to a kingdom with no way out, since a selfish dragon named Monsieur Marmadune also refuses to share the key to let them out of the kingdom and return to the beach party before it ends. Ord must learn to share something with the selfish dragon in order for him to let them borrow the key and continue the beach party.",
    category: ["cartoon" ],
    show: "Dragon Tales",
    videoUrl,
    thumbnailUrl,
    videoLength: duration,
    languages: ["Hindi"],
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  console.log("✅ Upload complete!");
}

run().catch(console.error);
