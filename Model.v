// VerilogA for FeFET, FeFET, veriloga

`include "constants.vams"
`include "disciplines.vams"

module FeFET(vdrain, vgate, vsource, vbody);
inout vdrain, vgate, vsource, vbody;
electrical vdrain, vgate, vsource, vbody;
    
parameter real width = 1u from (0:inf);
parameter real length = 1u from (0:inf);
parameter real vfb = 0 from (-inf:inf);
parameter real tfe = 0.8u from (0:inf);
parameter real til = 0.1u from (0:inf);
parameter real na = 3e17 from (0:inf);
parameter real epiv = 8.85e-14 from (0:inf);
parameter real epis = 11.8 from (0:inf);
parameter real epio = 3.9 from (0:inf);
parameter real a = 2.3 from (0:inf);
parameter real b = 0.4 from (0:inf);
parameter real p = 0.6775 from (0:inf);
parameter real q = 0.8115 from (0:inf);
parameter real Pr = 25 from (0:inf);
parameter real tauo = 1.9e-8 from (0:inf);
parameter real alpha = 3.0 from (0:inf);
parameter real beta = 2 from (0:inf);
parameter real epife = 28 from (0:inf);
parameter real miu = 50 from (0:inf);
parameter real TIMELIMIT = 1e9 from (0:inf);
parameter integer ndom = 20 from (0:inf);
parameter integer seed0 = 1 from (0:inf);

   real vds, 
      vgs, 
      vbs, 
      vbd, 
      vgb,
      vgd,
      vth, 
      id, 
      ibs, 
      ibd,
      qgb,
      qgs,
      qgd,
      qbd,
      qbs;
   real vswitchlimit[0:ndom-1], vswitch[0:ndom-1], r_Ea[0:ndom-1], f_Ea[0:ndom-1], r_voff[0:ndom-1], h[0:ndom-1], hpre[0:ndom-1], St[0:ndom-1], taus[0:ndom-1], htemp[0:ndom-1], St_temp[0:ndom-1];
   real vpre, time_pre, srand[0:ndom-1], Pleft, Pmid;
   real f_distr[0:9999], l[0:9999], Ea, k, E, sum, pswi, left, right, vfe, phis, phid, Cox, gamma, Pcurr;
   integer seed, i, j, m, flag, cnt;
   
   analog function real gamma_function;
      input x;
      real x, fact, c[0:19], accm;
      integer i;
      begin
         fact = 1.0;
         c[0] = sqrt(2.0 * `M_PI);
         for (i = 1; i < 20; i = i + 1) begin
            c[i] = exp(20-i) * pow(20-i, i-0.5) / fact;
            fact = -fact * i;
         end
         accm = c[0];
         for (i = 0; i < 20; i = i + 1) begin
            accm = accm + c[i] / (x + i);
         end
         accm = accm * exp(-(x+20)) * pow(x+20, x+0.5);
         gamma_function = accm/x;
      end
   endfunction

   analog function real beta_function;
      input x, y;
      real x, y;
      begin
         beta_function = gamma_function(x) * gamma_function(y) / gamma_function(x + y);
      end
   endfunction
   
   analog function real phi;
      input tox, Cox, gamma, W, L, VGB, VFB, VCB;
      real tox, Cox, gamma, W, L, VGB, VFB, VCB;
      real n_i, Vt, LD, phib, alpha_0, phix, phisat, ug, uc, ec, K, e1, e2, x, y, err, F_D;
      real qg, f, df, ddf;
      integer cnt;
      begin
         n_i = 5.29 * 1e19 * pow(($temperature / 300), 2.54) * exp(-6726 / $temperature);
         Vt = `P_K * $temperature / `P_Q;
         LD = sqrt(Vt * epis * epiv / na / `P_Q);
         phib = Vt * ln(na /n_i);     
         phix = 0;
         alpha_0 = -gamma * sqrt(Vt);
         ug = VGB - VFB;
         uc = VCB + 2 * phib;
         ec = exp(-uc / Vt);
         K = 1 - ec;
         if (uc > 0) begin
            phisat = ug + pow(gamma, 2) / 2 * (1 - sqrt(max(0, 1 + 4 * (ug - Vt) / pow(gamma, 2))));
            if (phisat >= uc && ug > 0) phix = uc + Vt * ln(max(1, pow(ug - uc, 2) / (pow(gamma, 2) * Vt)));
            else if (ug < alpha_0) phix = -2 * Vt * ln(ug / alpha_0);
            else if (ug > max(0, Vt)) phix = phisat;
            if (ug > 0) phix = min(ug, phix);
            else phix = max(ug, phix);
         end
         cnt = 0;
         err = 1;
         while (err > 1e-12 && cnt < 50) begin
            qg = ug - phix;
            e1 = 0;
            e2 = 0;
            x = (phix - uc)/Vt;
            y = -phix / Vt;
            if (x > -30) e1 = exp(x);
            if (y > -30) e2 = exp(y);
            f = pow(qg, 2) / pow(gamma, 2) - Vt * (e1 - ec + e2 - 1) - K * phix;
            df = e2 - e1 - 2 * qg / pow(gamma, 2) - K;
            ddf = 2 / pow(gamma, 2) - (e1 + e2) / Vt;
            phix = phix - f / (df - f * ddf / (2 * df));
            cnt = cnt + 1;
            F_D = (exp(-1.0 * phix / Vt) + phix / Vt - 1 ) + pow(n_i/na, 2) * exp(- VCB / Vt) * ( exp( phix / Vt) - phix / Vt - 1 - (pow(phix / Vt, 2) / (pow(phi / Vt, 2) + 2)) );
            if (F_D >= -1e-9) F_D = sqrt(abs(F_D));
            else F_D = 0;
            err = abs(sqrt(2) * (phix > 0 ? 1.0 : -1.0) * epis * epiv * Vt / LD * F_D / Cox + phix - (VGB - VFB));
         end
         phi = phix;
      end
   endfunction
   
   analog function real Qmos;
      input tox, phis, phid, Cox, gamma, W, L, VGB, VFB;
      real tox, phis, phid, Cox, gamma, W, L, VGB, VFB;
      real Vt, phim, dphi, Q, alpha_0, qim, H;
      begin
         Vt = `P_K * $temperature / `P_Q;
         phim = (phis + phid) / 2.0;
         dphi = phid - phis;
         if (VGB < VFB || abs(VGB - VFB) <= 1e-9) begin
            Q = Cox * W * L * (VGB - VFB - phim);
         end else begin
            alpha_0 = 1 + gamma / 2 / sqrt(phim);
            qim = VGB - VFB - phim - gamma * sqrt(phim);
            H = qim / alpha_0 + Vt;
            Q = Cox * W * L * (VGB - VFB - phim + pow(dphi, 2) / (12 * H));
         end
         Qmos = Q / W / L;
      end
   endfunction
      
   analog function real ID;
      input phis, phid, Cox, gamma, W, L, VGB, VFB;
      real phis, phid, Cox, gamma, W, L, VGB, VFB;
      real Vt, phim, dphi, Q, alpha_0, qim, H;
      begin
         Vt = `P_K * $temperature / `P_Q;
         phim = (phis + phid) / 2.0;
         dphi = phid - phis;
         if (VGB < VFB || abs(VGB - VFB) <= 1e-9) begin
            qim = 0;
            alpha_0 = 0;
         end else begin
            alpha_0 = 1 + gamma / 2 / sqrt(phim);
            qim = (VGB - VFB - phim - gamma * sqrt(phim));
         end
         ID = W / L * miu * Cox * (qim + alpha_0 * Vt) * dphi;
      end
   endfunction
      
   analog begin

      @ ( initial_step or initial_step("static") ) begin
		 seed = seed0;
         time_pre = $abstime;
         for (i = 0; i < ndom; i = i + 1) begin
            r_voff[i] = $rdist_normal(seed, 0, abs(vfb)) * (vfb <= 0 ? 1.0 : -1.0);
            r_Ea[i] = $rdist_normal(seed, a, b);
            vswitchlimit[i] = r_Ea[i]/pow(ln(TIMELIMIT/tauo), 1.0/alpha);
            St[i] = ($random(seed) % 2) ? 1 : -1;
            h[i] = 0;
         end
         Cox = epio * epiv / til;
         gamma = sqrt(2 * `P_Q * na * epis * epiv) / Cox;
      end
	
      vds = V(vdrain, vsource);
      vgs = V(vgate, vsource);
      vgb = V(vgate, vbody);
      vgd = V(vgate, vdrain);
      vbs = V(vbody, vsource);
      vbd = V(vbody, vdrain);

      for (i = 0; i < ndom; i = i + 1) begin
         srand[i] = $rdist_uniform(seed, 0, 1);
      end

      vfe = vpre;
      left = vpre - 10;
      right = vpre + 10;
      cnt = 0;
      for (cnt = 0; cnt < 50; cnt = cnt + 1) begin
         // left compute
         sum = 0;
         for (i = 0; i < ndom; i = i + 1) begin
            vswitch[i] = (left + vpre) / 2.0 - r_voff[i];
            taus[i] = tauo * exp(pow(r_Ea[i]/max(abs(vswitch[i]), vswitchlimit[i]), alpha));
            htemp[i] = hpre[i] + ($abstime - time_pre) * (vswitch[i] * St[i] <= 0 ? 1.0 : -1.0) / taus[i];
            
            if (hpre[i] > htemp[i]) begin
               pswi = -0.1;
            end else begin
               pswi = 1 - exp(pow(hpre[i], beta) - pow(htemp[i], beta));
            end
         
            if (htemp[i] < 0 || pswi > srand[i]) begin
               htemp[i] = 0;
            end
            
            
            if (pswi > srand[i]) begin
               St_temp[i] = -St[i];
            end else begin
               St_temp[i] = St[i];
            end
            
            sum = sum + St_temp[i];
         end
         phis = phi(til, Cox, gamma, width, length, vgb - left, -vfb, -vbs);
         phid = phi(til, Cox, gamma, width, length, vgb - left, -vfb, -vbd);
         
         Pleft = Pr * sum / ndom + 1e6 * left * epife * epiv / tfe - 1e6 * Qmos(til, phis, phid, Cox, gamma, width, length, vgb - left, -vfb);
         // Todo: Add weight for domains
         
         // mid compute
         sum = 0;
         for (i = 0; i < ndom; i = i + 1) begin
            vswitch[i] = (vfe + vpre) / 2.0 - r_voff[i];
            taus[i] = tauo * exp(pow(r_Ea[i]/max(abs(vswitch[i]), vswitchlimit[i]), alpha));
            htemp[i] = hpre[i] + ($abstime - time_pre) * (vswitch[i] * St[i] <= 0 ? 1.0 : -1.0) / taus[i];
            
            if (hpre[i] > htemp[i]) begin
               pswi = -0.1;
            end else begin
               pswi = 1 - exp(pow(hpre[i], beta) - pow(htemp[i], beta));
            end
         
            if (htemp[i] < 0 || pswi > srand[i]) begin
               htemp[i] = 0;
            end
            
            if (pswi > srand[i]) begin
               St_temp[i] = -St[i];
            end else begin
               St_temp[i] = St[i];
            end
            
            sum = sum + St_temp[i];
         end
         phis = phi(til, Cox, gamma, width, length, vgb - vfe, -vfb, -vbs);
         phid = phi(til, Cox, gamma, width, length, vgb - vfe, -vfb, -vbd);
         
         Pmid = Pr * sum / ndom + 1e6 * vfe * epife * epiv / tfe - 1e6 * Qmos(til, phis, phid, Cox, gamma, width, length, vgb - vfe, -vfb);
         
         if (Pmid * Pleft <= 0) begin
            right = vfe;
            vfe = (left + right) / 2;
         end else begin
            left = vfe;
            vfe = (left + right) / 2;
         end
      end
      
      sum = 0;
      for (i = 0; i < ndom; i = i + 1) begin
         vswitch[i] = (vfe + vpre) / 2.0 - r_voff[i];
         taus[i] = tauo * exp(pow(r_Ea[i]/max(abs(vswitch[i]), vswitchlimit[i]), alpha));
         h[i] = hpre[i] + ($abstime - time_pre) * (vswitch[i] * St[i] <= 0 ? 1.0 : -1.0) / taus[i];
         
         if (hpre[i] > h[i]) begin
            pswi = -0.1;
         end else begin
            pswi = 1 - exp(pow(hpre[i], beta) - pow(h[i], beta));
         end
		
         if (h[i] < 0 || pswi > srand[i]) begin
            h[i] = 0;
         end
         
         if (pswi > srand[i]) begin
            St[i] = -St[i];
         end
         
         hpre[i] = h[i];
         sum = sum + St[i];
      end
      
      vpre = vfe;
      time_pre = $abstime;
      phis = phi(til, Cox, gamma, width, length, vgb - vfe, -vfb, -vbs);
      phid = phi(til, Cox, gamma, width, length, vgb - vfe, -vfb, -vbd);
      id = ID(phis, phid, Cox, gamma, width, length, vgb - vfe, -vfb);
      Pcurr = Pr * sum / ndom + 1e6 * (vgb - vfe) * epife * epiv / tfe;

      I(vdrain, vsource) <+ id;
      I(vbody, vdrain)   <+ 0;
      I(vbody, vsource)  <+ 0;
      I(vgate, vbody)    <+ 0;
      I(vgate, vsource)  <+ 0;
      I(vgate, vdrain)   <+ 0;
   end
endmodule
