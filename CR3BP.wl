(* ::Package:: *)

(* ::Text:: *)
(*Mathematical library for the CR3BP Explorer*)
(*Version 0.2*)
(*(c) 2018 Pavel Hajek*)


BeginPackage["CR3BP`"];

Unprotect@@Names["CR3BP`*"]; 

ClearAll@@Names["CR3BP`*"];

(* On reload, discard the previous implementation, including legacy private
   option symbols, before resolving the public options below. *)
Unprotect@@Names["CR3BP`Private`*"];
Remove["CR3BP`Private`*"];

InitialAx::usage="InitialAx is the starting amplitude used by getLinearizedPeriodicOrbitIC.";
InitialCondition::usage="InitialCondition is the initial matrix used by getSTM.";
Vx1Order::usage="Vx1Order specifies the decimal order required for the shooting residual.";
Iterations::usage="Iterations is the maximum number of shooting iterations.";
DoAllIterations::usage="DoAllIterations forces all shooting iterations before checking the result.";
MaxCrossingTime::usage="MaxCrossingTime is the maximum time used to find a shooting crossing.";
CrossValue::usage="CrossValue is the coordinate value defining the crossing plane.";
CrossCount::usage="CrossCount is the maximum number of accepted crossings.";
TestFunction::usage="TestFunction selects accepted phase-space crossings.";
PointCount::usage="PointCount is the number of manifold initial conditions.";
ClosedOrbit::usage="ClosedOrbit controls whether the final orbit sample is omitted.";
MinimalTime::usage="MinimalTime is the lower integration time for manifold trajectories.";
MaximalTime::usage="MaximalTime is the upper integration time for manifold trajectories.";
ReturnSolutions::usage="ReturnSolutions controls whether manifold trajectories are returned.";
Epsilon::usage="Epsilon is the signed displacement from the periodic orbit.";
MonodromyMatrix::usage="MonodromyMatrix optionally supplies a precomputed monodromy matrix.";
MaximalDisplacementParameter::usage="MaximalDisplacementParameter limits the continuation seed search.";

\[Mu]::usage="Mass parameter. Needs to be initialized by set\[Mu][\[Mu]].";

xS::usage="Position of the first mass (Sun)";

rS::usage="Radius of the first mass (Sun)";

xJ::usage="Position of the second mass (Jupiter)";

rJ::usage="Radius of the second mass (Jupiter)";

set\[Mu]::usage="set\[Mu][x] sets \[Mu]=x. There are predefined values for x=\"Sun-Jupiter\", \"Earth-Moon\", \"Pluto-Charon\"";

rotatingToSpatial::usage="rotatingToSpatial[t,{x,y}] converts coordinates {x,y} in the rotating frame to coordinates in the inertial frame.";

energy::usage="energy[{x,y,vx,vy}] gives the energy of the point in phase space with coordinates {x,y,vx,vy} in the rotating frame.";

Ueff::usage="Ueff[{x,y}] effective potential of the spatial point with coordinates {x,y} in the rotating frame.";



set\[Mu]AndLagrangePoints::usage="set\[Mu]AndLagrangePoints[\[Mu]] sets \[Mu] (see 'set\[Mu]') and calculates Lagrange Points.";

lagrangePoints::usage="List of Lagrange Points initialized by set\[Mu]AndLagrangePoints[\[Mu]]";

linearToRotating::usage="linearToRotating[lpnum,{\[Xi],\[Eta],\[Zeta]1,\[Zeta]2}] converts coordinates {\[Xi],\[Eta],\[Zeta]1,\[Zeta]2} of the linearization at the Lagrange point number 'lpnum' to the coordinates {x,y,vx,vy} in the rotating frame.";

rotatingToLinear::usage="rotatingToLinear[lpnum,{x,y,vx,vy}] converts coordinates {x,y,vx,vy} in the rotating frame to the coordinates {\[Xi],\[Eta],\[Zeta]1,\[Zeta]2} of the linearization at the Lagrange point number 'lpnum'.";



linearEnergy::usage="linearEnergy[lpnum,{\[Xi],\[Eta],\[Zeta]1,\[Zeta]2}] gives the linearized energy of the point with coordinates {\[Xi],\[Eta],\[Zeta]1,\[Zeta]2} in the linearization at the Lagrange point number 'lpnum'.";


getLinearSolution::usage="getLinearSolution[lpnum,{\[Xi]0,\[Eta]0,\[Zeta]10,\[Zeta]20}] gives the solution of the linearized system at the Lagrange point number 'lpnum' with initial condition {\[Xi]0,\[Eta]0,\[Zeta]10,\[Zeta]20} in the linearized frame as a function sol[t] such that sol[t][[k]],k=1,...,4 are its coordinates {x,y,vx,vy} in the rotating frame.";

getLinearizedPeriodicOrbitIC::usage="getLinearizedPeriodicOrbitIC[lpnum,en] finds the initial condition IC={x0,y0,vx0,vy0} in the rotating frame of energy en=energy[IC] of the periodic orbit of the system linearized at the Lagrange point lpnum. Optional parameters are those of 'FindRoot' and 'InitialAx->0', which is the initial radius \!\(\*SubscriptBox[\(a\), \(x\)]\).";



getOrbit::usage="getOrbit[{x0,y0,vx0,vy0},{tmin,tmax}] gives the orbit {x[t],y[t],vx[t],vy[t]} on the requested interval, with the specified rotating-frame initial condition at time 0. Negative times propagate backward. Optional parameters are those of NDSolve.";

getSTM::usage="getSTM[orb,{mint,maxt}] returns the state transition matrix \[Phi][t][[i,j]] along the orbit 'orb' with respect to the rotating frame. Optional parameters are those of 'NDSolve' and 'InitialCondition->IdentityMatrix[4]'.";

getPeriodicOrbitIC::usage="getPeriodicOrbitIC[{x00,y00,vx00,vy00}] returns {{x0,y0,vx0,vy0},{0,T}}, where {x0,y0,vx0,vy0} is the approximate initial condition of a nearby symmetric periodic orbit and T is its approximate period. Works only for points in the form {x00,0,0,vy00} by \"shooting\", detecting the first point with y1=0 and adjusting the initial vy00 (keeping x00 fixed) by the method of differential corrections, so that 'vx1' gets smaller and smaller (ideally to 0).  The search stops when either 'vx1' has order of 'Vx1Order->4' or the number 'Iterations->50' of iterations exceeds. If 'DoAllIterations->False' is set to True, all the specified iterations are done. If 'MaxCrossingTime->Infinity' is specified, the search for the y1=0 crossings stops after this time. The other options are those of getOrbitCrossings (and getSTM).";

getOrbitCrossings ::usage="getOrbitCrossings[axis,{x0,y0,vx0,vy0},{mint,maxt}] where returns the list {orbit,{{t1,{x1,y1,vx1,vy1}},{t2,{x2,y2,vx2,vy2}},...} of an orbit 'orbit' in the rotating coordinates and pairs of a time 'ti' between 'mint' and 'maxt' and a point '{xi,yi,vxi,vyi}=Table[orbit[[k]][ti],{k,1,4}]' where holds xi=='CrossValue' (if 'axis'=\"x\") or yi=='CrossValue' (if 'axis'=\"y\") and the condition 'TestFunction[{xi,yi,vxi,vyi}]'. Maximally 'CrossCount->1' crossings is detected until the computation of the orbit stops (so it stops either on CrossCount detections or at time maxt). Default options are 'CrossValue->0', 'CrossCount->1' and 'TestFunction->Function[x,True]'. The 'axis' and the 'TestFunction' can be set to one of the predefined 'ysection1Q' and \"y\", 'xsection2Q' and \"x\", 'xsection3Q' and \"x\" or 'ysection4Q' and \"y\". Other optional parameters are those of 'NDSolve'.";

getNextPeriodicOrbitSeed::usage="getNextPeriodicOrbitSeed[lyaporb,{tmin,tmax},deltaenergy] returns a guess of the initial condition {x0,y0,vx0,vy0} of a periodic orbit with energy E=energy[lyaporb[tmin]]+deltaenergy. Optional parameters are MaximalDisplacementParameter and MonodromyMatrix.";

getParamCrossings::usage="getParamCrossings[axis,orbit,Y,{orbmint,orbmaxt}] returns the list {{o1.1st,o2.1st,...},{o1.2nd,o2.2nd,...},...} of 1st, 2nd,... intersections of 'PointCount->10' orbits starting at points placed time-equidistantely at the orbit 'orbit' at time 'ti' and displaced by 'Y[ti]' with the section specified as in 'getOrbitCrossings'.
If 'ClosedOrbit->True' is True, an initial condition is taken at 'orbit[orbmint]' and not at 'orbit[orbmaxt]'. If False, an initial condition is taken at both points. If 'ReturnSolutions->False' is True, the function will return a list 'list' instead, such that 'list[[k]]={{o1,{o1.t1,...,o1.tk}},{o2,{o2.t1,...,o2.tk}},...}' is a list of orbits 'oi' with exactly 'k' crossings at times 'oi.t1,...,oi.tk'. The evaluation of the orbits proceeds only between 'MinimalTime->0' and 'MaximalTime->Infinity'. The other optional parameters are those of 'getOrbitCrossings' (and 'getSTM').";

getPoincareSection::usage=
"getPoincareSection[manifold,axis,orbit,{orbmint,orbmaxt}] returns the Poincare section of the unstable (manifold=\"u\") or stable (manifold=\"s\") manifold of the periodic orbit 'orbit'. It calls 'getParamCrossings[axis,orbit,Y,{orbmint,orbmaxt}]' with 'Y' computed from the eigenvectors of the monodromy matrix of the periodic orbit multiplied by 'Epsilon->0.0001'. Other options are those of 'getParamCrossings' (and 'getSTM' for the monodromy matrix).";

orbitPlot::usage="orbitPlot[orbit,{tmin,tmax}] plots a previously computed orbit in rotating-frame position coordinates. Options are those of ParametricPlot.";
sectionPlot::usage="sectionPlot[points,{i,j}] plots coordinates i and j of a list of previously computed crossing states; {1,3} is the default. Options are those of ListPlot.";
scenePlot::usage="scenePlot[association,keys] displays selected named Graphics layers. Use All to display all layers. The layers are reused; scenePlot does not integrate trajectories. Options are those of Graphics.";

ysection1Q::usage="ysection1Q[{x,y,vx,vy}] tests (x<0)&&(vy<0). It corresponds to \!\(\*SubscriptBox[\(U\), \(1\)]\)={x<0,vy<0,y=0}." ;

xsection2Q::usage="xsection2Q[{x,y,vx,vy}] tests (y<0)&&(vx>0). It corresponds to \!\(\*SubscriptBox[\(U\), \(2\)]\)={x=1-\[Mu],y<0,vx>0}." ;

xsection3Q::usage="xsection3Q[{x,y,vx,vy}] tests (y>0)&&(vx<0). It corresponds to \!\(\*SubscriptBox[\(U\), \(3\)]\)={x=1-\[Mu],y>0,vx<0}." ;

ysection4Q::usage="ysection4Q[{x,y,vx,vy}] tests (x<-1)&&(vy>0). It corresponds to \!\(\*SubscriptBox[\(U\), \(4\)]\)={x<-1,vy>0,y=0}." ;



Begin["`Private`"];


\[Mu];

\[Mu]1=1-\[Mu];

\[Mu]2=\[Mu]; 

xS={-\[Mu]2,0};

rS={"Pluto-Charon"->1187/19570,"Earth-Moon"-> 6371/384400,"Sun-Jupiter"->695700/778547200, HoldPattern[_]->0.02};

xJ={\[Mu]1,0}; 

rJ={"Pluto-Charon"->606/19570,"Earth-Moon"-> 1737/384400,"Sun-Jupiter"->69911/778547200, HoldPattern[_]->0.02};

lagrangePts;

\[Mu]bar=\[Mu] Abs[xe-1+\[Mu]]^(-3)+(1-\[Mu])Abs[xe+\[Mu]]^(-3);

a=2\[Mu]bar+1;

b=\[Mu]bar-1;

\[Tau]=-((\[Nu]^2+a)/(2\[Nu]));

\[Lambda]=Sqrt[(\[Mu]bar-2+Sqrt[9\[Mu]bar^2-8\[Mu]bar])/2];

\[Nu]=Sqrt[(-\[Mu]bar+2+Sqrt[9\[Mu]bar^2-8\[Mu]bar])/2]; (* p.46 *)

k2pr=2\[Lambda]/(\[Lambda]^2+\[Mu]bar-1);

u1={1,-k2pr,\[Lambda],-\[Lambda] k2pr};

u2={1,k2pr,-\[Lambda],-\[Lambda] k2pr};

w1={1,- I \[Tau],I \[Nu], \[Nu] \[Tau]};

w2={1,I \[Tau], -I \[Nu], \[Nu] \[Tau]};



set\[Mu][x_]:=(Unprotect[\[Mu]]; 
\[Mu]=Switch[x,
"Sun-Jupiter",9537/10000000,
"Earth-Moon",1215/100000,
"Pluto-Charon",1097/10000,
_?NumberQ,x];
 Protect[\[Mu]]);


rotatingToSpatial[t_,{x_,y_}]:={{Cos[t],-Sin[t]},{Sin[t],Cos[t]}} . {x,y};


energy[{x_,y_,vx_,vy_}]:= 1/2(vx^2+vy^2)+Ueff[{x,y}];


Ueff[x_]:=-1/2(\[Mu]1 #1^2+\[Mu]2 #2^2)-\[Mu]1/#1-\[Mu]2/#2 & [EuclideanDistance[x,xS],EuclideanDistance[x,xJ]];


Ueffx[{x_,y_}]:=\[Mu] (-1+x+\[Mu]) (-1+1/(y^2+(-1+x+\[Mu])^2)^(3/2))+((-1+\[Mu]) (x+\[Mu]) (-1+(y^2+(x+\[Mu])^2)^(3/2)))/(y^2+(x+\[Mu])^2)^(3/2);
(* FullSimplify[Derivative[1,0][Ueff][x,y],Element[x|y|\[Mu],Reals]]//Evaluate; *)



Ueffy[{x_,y_}]:=y (-1+\[Mu]/(y^2+(-1+x+\[Mu])^2)^(3/2)+1/(y^2+(x+\[Mu])^2)^(3/2)-\[Mu]/(y^2+(x+\[Mu])^2)^(3/2));
(* FullSimplify[Derivative[0,1][Ueff][x,y],Element[x|y|\[Mu],Reals]]//Evaluate; *)


f[{x_,y_,vx_,vy_}]:={vx,vy,2vy-Ueffx[{x,y}],-2 vx - Ueffy[{x,y}]}; (* x'(t)=f(x(t)) *)


Df[{x_,y_,vx_,vy_}]:=FunctionExpand[D[f[{x,y,vx,vy}],{{x,y,vx,vy}}],Element[x|y|vx|vy|\[Mu],Reals]]//Evaluate;
(*{{0,0,1,0},{0,0,0,1},{(3 \[Mu] (-1+x+\[Mu])^2)/(y^2+(-1+x+\[Mu])^2)^(5/2)-(3 (-1+\[Mu]) (x+\[Mu])^2)/(y^2+(x+\[Mu])^2)-\[Mu] (-1+1/(y^2+(-1+x+\[Mu])^2)^(3/2))+(3 (-1+\[Mu]) (x+\[Mu])^2 (-1+(y^2+(x+\[Mu])^2)^(3/2)))/(y^2+(x+\[Mu])^2)^(5/2)-((-1+\[Mu]) (-1+(y^2+(x+\[Mu])^2)^(3/2)))/(y^2+(x+\[Mu])^2)^(3/2),(3 y \[Mu] (-1+x+\[Mu]))/(y^2+(-1+x+\[Mu])^2)^(5/2)-(3 y (-1+\[Mu]) (x+\[Mu]))/(y^2+(x+\[Mu])^2)+(3 y (-1+\[Mu]) (x+\[Mu]) (-1+(y^2+(x+\[Mu])^2)^(3/2)))/(y^2+(x+\[Mu])^2)^(5/2),0,2},{-y (-((3 \[Mu] (-1+x+\[Mu]))/(y^2+(-1+x+\[Mu])^2)^(5/2))-(3 (x+\[Mu]))/(y^2+(x+\[Mu])^2)^(5/2)+(3 \[Mu] (x+\[Mu]))/(y^2+(x+\[Mu])^2)^(5/2)),1-\[Mu]/(y^2+(-1+x+\[Mu])^2)^(3/2)-1/(y^2+(x+\[Mu])^2)^(3/2)+\[Mu]/(y^2+(x+\[Mu])^2)^(3/2)-y (-((3 y \[Mu])/(y^2+(-1+x+\[Mu])^2)^(5/2))-(3 y)/(y^2+(x+\[Mu])^2)^(5/2)+(3 y \[Mu])/(y^2+(x+\[Mu])^2)^(5/2)),-2,0}};*)



Options[set\[Mu]AndLagrangePoints]=Options[FindRoot];


set\[Mu]AndLagrangePoints[\[Mu]val_,opt:OptionsPattern[]]:=Module[{l1x,l2x,l3x},

set\[Mu][\[Mu]val];

Unprotect[lagrangePts];

With[{op=FilterRules[{opt},Options[FindRoot]]},

lagrangePts={{l1x,0},{l2x,0},{l3x,0},xS+{1/2,Sqrt[3]/2},xS+{1/2,-Sqrt[3]/2}}/.

Flatten[{FindRoot[Ueffx[{l1x,0}],{l1x,0},op],FindRoot[Ueffx[{l2x,0}],{l2x,1},op],FindRoot[Ueffx[{l3x,0}],{l3x,-1},op]}];

]

Protect[lagrangePts];

lagrangePts

];



lagrangePoints=lagrangePts;


linearToRotating[lpnum_,{\[Xi]_,\[Eta]_,\[Zeta]1_,\[Zeta]2_}]:=With[{lp=lagrangePts[[lpnum]]},

Join[lp,{0,0}]+Transpose[{u1,u2,Re[w1],Im[w1]}] . {\[Xi],\[Eta],\[Zeta]1,\[Zeta]2}/.xe->lp[[1]]

];



rotatingToLinear[lpnum_,{x_,y_,vx_,vy_}]:=With[{lp=lagrangePts[[lpnum]]},

Inverse[Transpose[{u1,u2,Re[w1],Im[w1]}/.xe->lp[[1]]]] . ({x,y,vx,vy}-Join[lp,{0,0}])

];


linearEnergy[lpnum_,{\[Xi]_,\[Eta]_,\[Zeta]1_,\[Zeta]2_}]:=With[{lp=lagrangePts[[lpnum]]},

\[Lambda] \[Xi] \[Eta]+\[Nu]/2(\[Zeta]1^2+\[Zeta]2^2)+Ueff[lp]/. xe->lp[[1]]

];




getLinearSolution[lpnum_,{\[Xi]0_,\[Eta]0_,\[Zeta]10_,\[Zeta]20_}]:=

t |-> Evaluate[linearToRotating[lpnum,{\[Xi]0 Exp[\[Lambda] t],\[Eta]0 Exp[-\[Lambda] t],\[Zeta]10 Cos[-\[Nu] t] +\[Zeta]20 Sin[\[Nu] t],\[Zeta]10 Sin[-\[Nu] t] + \[Zeta]20 Cos[\[Nu] t]}]/. xe->lagrangePts[[lpnum]]];



Options[getLinearizedPeriodicOrbitIC]=Join[Options[FindRoot],{InitialAx -> 0}];

getLinearizedPeriodicOrbitIC[lpnum_,en_,opt:OptionsPattern[]]:=

If[en>=Ueff[lagrangePts[[lpnum]]],

linearToRotating[lpnum,

{0, 0, -FindRoot[

energy[linearToRotating[lpnum,{0,0,-u,0}]]==en,

{u,OptionValue[InitialAx]},

Evaluate[FilterRules[{opt},Options[FindRoot]]]

][[1,2]],

0}

]

,

$Failed

];





Options[getOrbit]=Options[NDSolve];

getOrbit[{x0_,y0_,vx0_,vy0_},{tmin_,tmax_},opt:OptionsPattern[]]:=

Module[{x,y,vx,vy},

NDSolveValue[{

{x'[t],y'[t],vx'[t],vy'[t]}==f[{x[t],y[t],vx[t],vy[t]}],

{x[0],y[0],vx[0],vy[0]}=={x0,y0,vx0,vy0}

},

{x,y,vx,vy},

{t,tmin,tmax},

FilterRules[{opt},Options[NDSolve]]

]

];







Options[getSTM]=Join[Options[NDSolve],{InitialCondition->IdentityMatrix[4]}];

getSTM[orb_,{mint_,maxt_},opt:OptionsPattern[]]:=

Module[

{A,B},

B[t_]:=Df[{orb[[1]][t],orb[[2]][t],orb[[3]][t],orb[[4]][t]}];

NDSolveValue[

{A'[t]==B[t] . A[t],

A[0]==OptionValue[InitialCondition]},

A,

{t,mint,maxt},

FilterRules[{opt},Options[NDSolve]]

]

];






Options[getPeriodicOrbitIC]:=Join[Options[getOrbitCrossings],Options[getSTM],{Vx1Order->4,Iterations->50,DoAllIterations->False, MaxCrossingTime->Infinity}];

getPeriodicOrbitIC::nocross="No usable y=0 crossing was found during shooting. Increase MaxCrossingTime or change the seed.";
getPeriodicOrbitIC::singular="The differential correction is singular at the crossing; no periodic-orbit initial condition was returned.";
getPeriodicOrbitIC::noconv="Shooting did not reach the requested residual in `1` iterations.";

getPeriodicOrbitIC[{x00_,y00_,vx00_,vy00_},opt:OptionsPattern[]]:=


Module[{x0,y0,vx0,vy0,x1,y1,vx1,dvx1,u,vy1,t1,sol,orbit,stm,cnt,continue,denom,\[Phi]1},

{x0,y0,vx0,vy0}={x00,0,0,vy00};

continue=True;

cnt=1;

With[{
getOrbitCrossingsOpt=FilterRules[{opt},Options[getOrbitCrossings]],
getSTMOpt=FilterRules[{opt},Options[getSTM]]
},

(* Keep the precision actually supplied by the seed and numerical solutions.
   A later integration cannot recover digits that were not computed here. *)

While[continue,

sol=getOrbitCrossings["y",
{x0,y0,vx0,vy0},
{0,OptionValue[MaxCrossingTime]},
getOrbitCrossingsOpt];

If[!MatchQ[sol, {_List, {{_?NumericQ, {__?NumericQ}}, ___}}],
Message[getPeriodicOrbitIC::nocross]; Return[$Failed]];

orbit=sol[[1]];

t1=sol[[2,1,1]];

{x1,y1,vx1,vy1}=sol[[2,1,2]];

continue=(cnt<OptionValue[Iterations])&&(OptionValue[DoAllIterations]||(Abs[vx1]>=10^(-OptionValue[Vx1Order])));

If[continue,

stm=getSTM[orbit,
{0,t1},
getSTMOpt];

If[Head[stm] =!= InterpolatingFunction,
Message[getPeriodicOrbitIC::singular]; Return[$Failed]];

\[Phi]1=stm[t1];

dvx1=D[orbit[[3]][u],u]/.u->t1;

If[PossibleZeroQ[vy1], Message[getPeriodicOrbitIC::singular]; Return[$Failed]];
denom=\[Phi]1[[3,4]]-dvx1/vy1 \[Phi]1[[2,4]];
If[!NumericQ[denom] || PossibleZeroQ[denom],
Message[getPeriodicOrbitIC::singular]; Return[$Failed]];
vy0=vy0 - vx1/denom;

cnt++

]

]

];

If[Abs[vx1]>=10^(-OptionValue[Vx1Order]),
Message[getPeriodicOrbitIC::noconv,cnt]; $Failed,
{{x0,y0,vx0,vy0},{0,2 t1}}]

];





Options[getNextPeriodicOrbitSeed]=Join[Options[getSTM],{MonodromyMatrix->Null,MaximalDisplacementParameter->10}];

getNextPeriodicOrbitSeed[lyaporb_,{tmin_,tmax_},deltaenergy_,opt:OptionsPattern[]]:=

Module[

{ic0,tanv,\[Phi]M,t,eigsys,sortedeigsys,ev1,ev2,dist,grad,deltav,u,t0,x,y,vx,vy},

ic0=Table[lyaporb[[i]][tmin],{i,1,4}]; (* Initial ic0 *)

tanv=Table[D[lyaporb[[i]][t],t]/.t->tmin,{i,1,4}]//Normalize; (* Tangent vector to the periodic orbit at ic0 *)

\[Phi]M=If[TrueQ[OptionValue[MonodromyMatrix]==Null],

getSTM[lyaporb,{tmin,tmax},FilterRules[{opt},Options[getSTM]]][tmax],

OptionValue[MonodromyMatrix]

]; (* Monodromy matrix *)

eigsys=Eigensystem[\[Phi]M];

sortedeigsys=Sort[Transpose[eigsys],#1[[1]]<=#2[[1]]&]; (* Eigenvalues are Subscript[\[Lambda], 1]<1, Subscript[\[Lambda], 2]=Subscript[\[Lambda], 3]=1, Subscript[\[Lambda], 4]>1 *)

ev1=sortedeigsys[[2,2]]//Normalize;

ev2=sortedeigsys[[3,2]]//Normalize; (* Eigenvectors to \[Lambda]=1 *)

dist=Map[Norm[tanv-#]&,{ev1,-ev1,ev2,-ev2}]; (* We want to take the eigenvector ev1 or ev2, which is not tanv *)

grad[{x_,y_,vx_,vy_}]:=FunctionExpand[Grad[energy[{x,y,vx,vy}],{x,y,vx,vy}],Element[x|y|vx|vy|\[Mu],Reals]]//Evaluate; (* Gradient of the energy *)

deltav=If[Min[dist[[1]],dist[[2]]]<Min[dist[[3]],dist[[4]]], 

If[grad[ic0] . ev2>0, ev2, -ev2],

If[grad[ic0] . ev1>0, ev1, -ev1]

];

deltav={deltav[[1]],0,0,deltav[[4]]};

t0=$Failed;

NDSolve[{u'[t]==grad[ic0+t*deltav] . deltav, u[0]==energy[ic0],

WhenEvent[u[t]==energy[ic0]+deltaenergy,t0=t;"StopIntegration"]},

{u},

{t,0,OptionValue[MaximalDisplacementParameter]},

FilterRules[{opt},Options[NDSolve]]

];

If[t0===$Failed,$Failed,ic0+t0*deltav]

];



Options[getOrbitCrossings]=Join[Options[NDSolve],{CrossValue->0,CrossCount->1,TestFunction->Function[x,True]}];

getOrbitCrossings[axis_,{x0_,y0_,vx0_,vy0_},{mint_,maxt_},opt:OptionsPattern[]]:=

(* Returns {{x[t],y[t],vx[t],vy[t]},{}} if no crossing or {{x[t],y[t],vx[t],vy[t]},{{t1,{x1,y1,vx1,vy1}}}} if one crossing or {{x[t],y[t],vx[t],vy[t]},{{t1,{x1,y1,vx1,vy1}},{t2,{x2,y2,vx2,vx2}},...}} if more crossings. *)

Module[

{x,y,vx,vy,cnt,subst},


With[{subst=If[axis=="y",y,x]},

MapAt[Flatten[#,1]&,

Reap@Most@NDSolveValue[{

{x'[t],y'[t],vx'[t],vy'[t]}==f[{x[t],y[t],vx[t],vy[t]}],

{x[0],y[0],vx[0],vy[0]}=={x0,y0,vx0,vy0},

cnt'[t]==0,

cnt[0]==1,

WhenEvent[subst[t]==OptionValue[CrossValue]&&OptionValue[TestFunction][{x[t],y[t],vx[t],vy[t]}],

Sow[{t,{x[t],y[t],vx[t],vy[t]}}];
 
If[cnt[t]<OptionValue[CrossCount],

cnt[t]->cnt[t]+1,

"StopIntegration"

]

]

},

{x,y,vx,vy,cnt},

{t,mint,maxt},

FilterRules[{opt},Options[NDSolve]]

],

2]

]

];








Options[getParamCrossings]:=Join[Options[getOrbitCrossings],{PointCount->10,ClosedOrbit->True,MinimalTime->0,MaximalTime->Infinity,ReturnSolutions->False}];

getParamCrossings[axis_,orbit_,vecfield_,{orbmint_,orbmaxt_},opt:OptionsPattern[]]:= 

Module[

{x,y,vx,vy,T,initialtimes,initialpts,res},

With[{cnt=OptionValue[PointCount]},

T=orbmaxt-orbmint;

initialtimes=If[OptionValue[ClosedOrbit],
Table[orbmint+T/cnt (k-1),{k,1,cnt}],
Table[orbmint+T/(cnt-1)(k-1),{k,1,cnt}]
];

initialpts=Map[
Table[orbit[[l]][#]+vecfield[#][[l]],{l,1,4}]&,
initialtimes];


If[OptionValue[ReturnSolutions],

res=Cases[

Table[getOrbitCrossings[axis,initialpts[[k]],{OptionValue[MinimalTime],OptionValue[MaximalTime]},FilterRules[{opt},Options[getOrbitCrossings]]],{k,1,cnt}]
(* Gives {{f1,{{f1t1,f1c1},{f1t2,f1c2},...}},{f2,{}},{f3,{{f3t1,f3c1}}},...} *)

,x_?(Part[#,2]!={}&):>{Part[x,1],Part[x,2,All,1]}
(* Returns {{f1,{f1t1,f1t2}},{f3,{f3t1}},...} of functions their ordered intersection times *)
];

SortBy[GatherBy[res,Length[#[[2]]]&],Length[#[[1,2]]]&]
 (* Gathers the list above by the number of intersection points *)

,

Flatten[

Table[

Part[
getOrbitCrossings[axis,initialpts[[k]],{OptionValue[MinimalTime],OptionValue[MaximalTime]},FilterRules[{opt},Options[getOrbitCrossings]]],
2,All,2] 

(* getOrbitCrossings returns {{x[t],y[t],vx[t],vy[t]},{{t1,{x1,y1,vx1,vy1}},{t2,{x2,y2,vx2,vx2}},...}}s. 
The function gives {{x1,y1,vx1,vy1},{x2,y2,vx2,vx2},...}. It is ordered after the order of intersection {1st,2nd,...}.   *)


,{k,1,cnt}]

,{2}] (* Input is the list {{o1.1st,o1.2nd,...},{o2.1st,o2.2nd,...},...}. The function in fact transposes this uneven matrix to the form {{o1.1st,o2.1st,...},{o1.2nd,o2.2nd,...},...}.
I.e. the first line contains 1st intersections of all orbits ordered after orbits.  The second line 2nd intersections...
If {{},{o2.1st,o2.2nd,...},...} it excludes out {} automatically and the result is {{o2.1st},{o2.2nd},...}. If {{},{}} the result is {}. *)
]

]

];




Options[getPoincareSection]=Join[Options[getParamCrossings],Options[getSTM],{Epsilon->1/10000}];


getPoincareSection[manifold_,axis_,orbit_,{orbmint_,orbmaxt_},opt:OptionsPattern[]]:=

Module[{Y,Y0,\[Phi]M,stm,eigsys,which},

stm=getSTM[orbit,{orbmint,orbmaxt},FilterRules[{opt},Options[getSTM]]];

If[Head[stm] =!= InterpolatingFunction, Return[$Failed]];

\[Phi]M=stm[orbmaxt];

eigsys=Eigensystem[\[Phi]M];
which=Switch[manifold,"s",First[Ordering[Abs[eigsys[[1]]],1]],
"u",First[Ordering[Abs[eigsys[[1]]],-1]],_,Return[$Failed]];
Y0=eigsys[[2,which]];

Y[t_]:=OptionValue[Epsilon] Normalize[stm[t] . Y0];


getParamCrossings[axis,orbit,Y,{orbmint,orbmaxt},FilterRules[{opt},Options[getParamCrossings]]]

];

Options[orbitPlot]=Options[ParametricPlot];
orbitPlot[orbit_List,{tmin_,tmax_},opt:OptionsPattern[]]:=
ParametricPlot[Evaluate[{orbit[[1]][t],orbit[[2]][t]}],{t,tmin,tmax},
Evaluate[Sequence@@FilterRules[{opt},Options[ParametricPlot]]]];

Options[sectionPlot]=Options[ListPlot];
sectionPlot[points_List,coordinates:{_Integer,_Integer}:{1,3},opt:OptionsPattern[]]:=
ListPlot[If[points==={}, {}, points[[All,coordinates]]],
FilterRules[{opt},Options[ListPlot]]];

Options[scenePlot]=Options[Graphics];
scenePlot[layers_Association,selection:(All|{___}),opt:OptionsPattern[]]:=
Module[{graphics=Values[If[selection===All,layers,KeyTake[layers,selection]]]},
If[graphics==={},Graphics[{},FilterRules[{opt},Options[Graphics]]],
Show[graphics,FilterRules[{opt},Options[Graphics]]]]];


ysection1Q[{x_,y_,vx_,vy_}]:=(x<0)&&(vy<0);  (* y=0 *)

xsection2Q[{x_,y_,vx_,vy_}]:=(y<0)&&(vx>0); (* x=1-\[Mu] *)

xsection3Q[{x_,y_,vx_,vy_}]:=(y>0)&&(vx<0); (* x=1-\[Mu] *)

ysection4Q[{x_,y_,vx_,vy_}]:=(x<-1)&&(vy>0); (* y=0 *)



End[];

Protect@@Names["CR3BP`*"];

EndPackage[];
