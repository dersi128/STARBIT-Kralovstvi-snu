"""Original STARBIT procedural score. Python + numpy + ffmpeg. No external samples."""
import numpy as np, wave, subprocess
from pathlib import Path
R=22050
out=Path(__file__).parent
rng=np.random.default_rng(71)
def save(name,a):
 a=a/(max(1,np.max(np.abs(a))/0.78))
 with wave.open(str(out/(name+'.wav')),'wb') as w:
  w.setnchannels(2);w.setsampwidth(2);w.setframerate(R);w.writeframes((a*32767).astype('<i2').tobytes())
 subprocess.run(['ffmpeg','-y','-loglevel','error','-i',str(out/(name+'.wav')),'-c:a','libvorbis','-q:a','5',str(out/(name+'.ogg'))],check=True)
 (out/(name+'.wav')).unlink()
def score(name,bpm,bars,boss=False):
 beat=60/bpm;length=bars*4*beat
 a=np.zeros((round(length*R),2))
 def note(m,start,dur,amp,kind='bell',pan=0):
  n=int(dur*R);t=np.arange(n)/R;f=440*2**((m-69)/12)
  env=np.minimum(t/.015,1)*np.minimum((dur-t)/.09,1)
  if kind=='bell':v=(np.sin(2*np.pi*f*t)*np.exp(-t*3)+.24*np.sin(2*np.pi*f*3*t)*np.exp(-t*8))*env
  elif kind=='pad':v=(np.sin(2*np.pi*f*t)+.18*np.sin(2*np.pi*f*2*t))*env*.7
  else:v=(np.sin(2*np.pi*f*t)+.3*np.sin(2*np.pi*f*2*t))*np.exp(-t*5)*env
  idx=(np.arange(n)+round(start*R))%len(a)
  for ch,g in enumerate([np.sqrt((1-pan)/2),np.sqrt((1+pan)/2)]):np.add.at(a[:,ch],idx,v*amp*g)
 chords=([ [57,60,64],[53,57,60],[55,59,62],[52,56,59] ] if boss else [[60,64,67],[57,60,64],[53,57,60],[55,59,62],[60,64,67],[64,67,71],[53,57,60],[55,59,62]])
 motifs=[[0,1,2,1,0,2,1,0],[2,1,0,1,2,2,1,0],[0,2,1,2,0,1,2,1],[2,1,0,0,1,2,1,0]]
 for b in range(bars):
  c=chords[b%len(chords)];at=b*4*beat
  for m in c:note(m,at,beat*3.9,.055,'pad',-.4)
  for k in range(8):
   note(c[k%3],at+k*beat/2,beat*.42,.075,'pluck',.5)
   if k not in ([3,7] if b%4==3 else [7]):
    note(c[motifs[(b//4)%4][k]]+12+(12 if b>=bars//2 and b%4==2 else 0),at+k*beat/2,beat*(.8 if k==6 else .46),.18,'bell',-.15)
  for k in range(4):
   note(c[0]-24+(7 if k==2 else 0),at+k*beat,beat*.8,.2,'bass')
   n=int(.17*R);t=np.arange(n)/R
   drum=np.sin(2*np.pi*(75*t-90*t*t))*np.exp(-t*30)*(.19 if boss else .075)
   if k%2:drum+=rng.normal(0,1,n)*np.exp(-t*40)*(.065 if boss else .018)
   idx=(round((at+k*beat)*R)+np.arange(n))%len(a)
   for ch in range(2):np.add.at(a[:,ch],idx,drum)
 if name=='victory':
  a*=np.minimum(np.arange(len(a))/R/.025,1)[:,None]
  a*=np.minimum((len(a)-np.arange(len(a)))/R/1.4,1)[:,None]
 save(name,a)
score('adventure',108,32)
score('boss',140,16,True)
score('victory',112,4)
t=np.arange(int(R*.68))/R
env=np.minimum(t/.02,1)*np.minimum((.68-t)/.12,1)
phase=2*np.pi*(125*t-48*t*t)
growl=(np.sin(phase)+.35*np.sin(2*phase)+.2*np.sin(3*phase))*(.75+.25*np.sin(t*2*np.pi*31))
noise=rng.normal(0,1,len(t));noise=np.convolve(noise,np.ones(12)/12,'same')
v=env*(growl*.32*np.exp(-t*2.5)+noise*.35*np.sin(np.pi*t/.68)**2)
save('bear_push',np.column_stack([v,v]))
print('Audio composed: adventure 71s, boss 27s, victory 9s, bear push 0.68s')
