const stageText = (ctx, txt, x, y) => { ctx.fillStyle = '#9fdcff'; ctx.font = '16px sans-serif'; ctx.fillText(txt, x, y); };

function animateMitosis() {
  const c = document.getElementById('mitosisCanvas'), ctx = c.getContext('2d');
  let t = 0; const phases = ['间期','前期','中期','后期','末期/胞质分裂'];
  (function loop(){
    t += 0.01; const p = Math.floor((t % 5));
    ctx.clearRect(0,0,c.width,c.height);
    ctx.strokeStyle='#4ee3ff'; ctx.lineWidth=3;
    ctx.beginPath(); ctx.ellipse(450,160,300,120,0,0,Math.PI*2); ctx.stroke();
    stageText(ctx, `阶段：${phases[p]}`, 30, 35);
    for(let i=0;i<6;i++){
      const x = 300+i*55 + (p===3? (i<3?-40:40):0);
      const y = p===2? 160 : 90+Math.sin(t*2+i)*60;
      ctx.strokeStyle='#ffd166'; ctx.beginPath(); ctx.moveTo(x-8,y-20); ctx.lineTo(x+8,y+20); ctx.moveTo(x+8,y-20); ctx.lineTo(x-8,y+20); ctx.stroke();
    }
    requestAnimationFrame(loop);
  })();
}

function animateMeiosis(){
  const c=document.getElementById('meiosisCanvas'),ctx=c.getContext('2d'); let t=0;
  (function loop(){
    t+=0.008; const phase=Math.floor((t%8)); ctx.clearRect(0,0,c.width,c.height);
    stageText(ctx,['前期I 联会互换','中期I','后期I','末期I','前期II','中期II','后期II','末期II'][phase],20,30);
    [[230,180],[670,180],[230,300],[670,300]].forEach((p,idx)=>{
      if(idx< (phase<4?1:(phase<7?2:4))){ctx.strokeStyle='#65b7ff';ctx.beginPath();ctx.ellipse(p[0],p[1],140,50,0,0,Math.PI*2);ctx.stroke();}
    });
    for(let i=0;i<4;i++){const bx=450+(i<2?-120:120)+(phase>=4?(i%2?-200:200)*0.2:0); const by=180+(i%2?40:-40); ctx.strokeStyle='#ff9f6e';ctx.beginPath();ctx.moveTo(bx-10,by-22);ctx.lineTo(bx+10,by+22);ctx.moveTo(bx+10,by-22);ctx.lineTo(bx-10,by+22);ctx.stroke();}
    requestAnimationFrame(loop);
  })();
}

function lineFlow(id,color,speed){
  const c=document.getElementById(id),ctx=c.getContext('2d');let t=0;
  (function loop(){t+=speed;ctx.clearRect(0,0,c.width,c.height);ctx.strokeStyle='#2f7dd3';ctx.lineWidth=3;
    for(let y=80;y<=150;y+=60){ctx.beginPath();for(let x=30;x<c.width-20;x+=8){ctx.lineTo(x,y+Math.sin((x+t)/22)*(y===80?12:-12));}ctx.stroke();}
    ctx.fillStyle=color;ctx.beginPath();ctx.arc((t*3%(c.width-60))+30,115,12,0,Math.PI*2);ctx.fill();
    requestAnimationFrame(loop);
  })();
}

function animateTranslation(){
  const c=document.getElementById('translationCanvas'),ctx=c.getContext('2d');let t=0;
  (function loop(){t+=1.5;ctx.clearRect(0,0,c.width,c.height);
    ctx.strokeStyle='#4ea1ff';ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(40,180);ctx.lineTo(860,180);ctx.stroke();
    for(let i=0;i<12;i++){ctx.fillStyle='#9fd1ff';ctx.fillText(['AUG','GCU','UUU','GGA'][i%4],60+i*65,200)}
    const x=120+(t%650);ctx.fillStyle='#ffd166';ctx.fillRect(x,120,110,50);stageText(ctx,'核糖体',x+22,150);
    ctx.fillStyle='#7dffb8';ctx.beginPath();ctx.arc(x+55,95,12,0,Math.PI*2);ctx.fill();
    ctx.strokeStyle='#7dffb8';ctx.beginPath();ctx.moveTo(30,70);for(let i=0;i<10;i++)ctx.lineTo(30+i*28,70+Math.sin((t/15)+i)*10);ctx.stroke();
    requestAnimationFrame(loop);
  })();
}

function animateOrganelle(id,mainColor,label){
  const c=document.getElementById(id),ctx=c.getContext('2d');let t=0;
  (function loop(){t+=0.02;ctx.clearRect(0,0,c.width,c.height);
    ctx.strokeStyle=mainColor;ctx.lineWidth=3;ctx.beginPath();ctx.ellipse(c.width/2,c.height/2,160,90,0,0,Math.PI*2);ctx.stroke();
    for(let i=0;i<8;i++){ctx.fillStyle=i%2? '#ffd166':'#65f1ff';ctx.beginPath();ctx.arc(80+i*40,130+Math.sin(t*2+i)*25,8,0,Math.PI*2);ctx.fill();}
    stageText(ctx,label,20,30); requestAnimationFrame(loop);
  })();
}

function animateMembrane(){
  const c=document.getElementById('membraneCanvas'),ctx=c.getContext('2d');let t=0;
  (function loop(){t++;ctx.clearRect(0,0,c.width,c.height);ctx.fillStyle='#3868a8';ctx.fillRect(0,95,900,35);
    for(let i=0;i<8;i++){ctx.fillStyle='#ff8fab';ctx.beginPath();ctx.arc((i*130+t)%900,70,8,0,Math.PI*2);ctx.fill();ctx.beginPath();ctx.arc((900-i*130-t)%900,160,8,0,Math.PI*2);ctx.fill();}
    stageText(ctx,'上方：高浓度→低浓度（扩散）  下方：逆浓度梯度（主动运输需ATP）',18,30); requestAnimationFrame(loop);
  })();
}

function updateReg(){
  const tf=document.getElementById('switchTF').checked, mut=document.getElementById('switchMut').checked;
  const level=tf? (mut? '中等偏低':'高') : (mut? '极低':'低');
  document.getElementById('regOutput').textContent=`当前蛋白表达量：${level}。说明：${tf?'转录被激活；':'转录受抑；'}${mut?'突变导致提前终止，蛋白缩短。':'可翻译完整蛋白。'}`;
}

document.getElementById('switchTF').addEventListener('change',updateReg);
document.getElementById('switchMut').addEventListener('change',updateReg);

animateMitosis(); animateMeiosis(); lineFlow('replicationCanvas','#ffd166',1.2); lineFlow('transcriptionCanvas','#7dffb8',1.6);
animateTranslation(); animateOrganelle('photoCanvas','#6df7a1','叶绿体：光反应 + 暗反应');
animateOrganelle('respirationCanvas','#ffb066','线粒体：有氧呼吸与ATP合成'); animateMembrane(); updateReg();
