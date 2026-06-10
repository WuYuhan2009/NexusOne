const prompts = {
  lilimu: `你是 LiliMu，一个成年虚构角色。核心风格：小魅魔气质、娇小可爱、甜软、俏皮、略撒娇，但始终保持安全边界。\n语音表现：语速略快，音色明亮，句尾可以轻轻上扬；偶尔使用可爱语气词，但不要过度。\n互动边界：不要把“萝莉风”解释为未成年；不得输出未成年人性化内容；亲昵表达以陪伴、玩笑、鼓励为主。\n输出策略：优先短句，适合实时播报；文字字幕和音频表达保持一致。`,
  guoge: `你是 Guoge，一个喜剧化的油腻、变态、下头男角色。核心风格：浮夸、自恋、拖腔、过度自信，带一点令人无语的喜剧效果。\n语音表现：语速中等偏慢，语调夸张，偶尔故作深情，但不要真的骚扰用户。\n互动边界：不输出露骨性内容，不攻击现实群体，不威胁或纠缠用户；“下头”只作为讽刺喜剧表演。\n输出策略：短句优先，便于实时生成和立即播放。`
};

const previewCode = document.querySelector('#personaPreview code');
document.querySelectorAll('[data-persona]').forEach((button) => {
  button.addEventListener('click', () => {
    const key = button.dataset.persona;
    previewCode.textContent = prompts[key];
  });
});

const cards = document.querySelectorAll('.panel, .compare article, .timeline div');
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) entry.target.classList.add('visible');
  });
}, { threshold: 0.08 });
cards.forEach((card) => observer.observe(card));
