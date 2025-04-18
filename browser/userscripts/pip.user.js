// stolen from https://chromewebstore.google.com/detail/pip-picture-in-picture-pl/cejddnmmppcemhgenpcacdipichjjeme script.js
// still in work

function findLargestPlayingVideo() {
  const videos = Array.from(document.querySelectorAll('video'))
    .filter(video => video.readyState != 0)
    .filter(video => video.disablePictureInPicture == false)
    .sort((v1, v2) => {
      const v1Rect = v1.getClientRects()[0]||{width:0,height:0};
      const v2Rect = v2.getClientRects()[0]||{width:0,height:0};
      return ((v2Rect.width * v2Rect.height) - (v1Rect.width * v1Rect.height));
    });

  if (videos.length === 0) {
	chrome.runtime.sendMessage({'method':'setInfo','info':'errornovideo'});
    return;
  }

  return videos[0];
}

async function requestPictureInPicture(video) {
  await video.requestPictureInPicture().catch(error => {
        // Video failed to enter Picture-in-Picture mode.
		  chrome.runtime.sendMessage({'method':'setInfo','info':'errorenter'});
      });
  video.setAttribute('__pip__', true);
  video.addEventListener('leavepictureinpicture', event => {
    video.removeAttribute('__pip__');
  }, { once: true });
  new ResizeObserver(maybeUpdatePictureInPictureVideo).observe(video);
}

function maybeUpdatePictureInPictureVideo(entries, observer) {
  const observedVideo = entries[0].target;
  if (!document.querySelector('[__pip__]')) {
    observer.unobserve(observedVideo);
    return;
  }
  const video = findLargestPlayingVideo();
  if (video && !video.hasAttribute('__pip__')) {
    observer.unobserve(observedVideo);
    requestPictureInPicture(video);
  }
}

(async () => {
  const video = findLargestPlayingVideo();
  if (!video) {
    return;
  }
  if (video.hasAttribute('__pip__')) {
    document.exitPictureInPicture().catch(error => {
        // Video failed to exit Picture-in-Picture mode.
		  chrome.runtime.sendMessage({'method':'setInfo','info':'errorexit'});
      });
  } else {
	await requestPictureInPicture(video);
  }

  chrome.runtime.sendMessage({'method':'setInfo','info':'done'});
})();
