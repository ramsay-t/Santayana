theory Workroom3
imports "../theories/utp_csp"
begin
 
text {*
  The room has a temperature, and then it has three HVAC inputs: 
  the Air Handling Unit that feeds the central air duct system,
  and two Fan Coil Units that provide direct heating or cooling
  to this room using centrally supplied hot or cold water.
  It also interacts with the surrounding air in the Atrium,
  and only one temperature for that is modelled here, although
  it is instrumented at multiple points around the workroom.
*}
  
datatype ev_room = 
  env "real * real * real * real" | measure real
  
alphabet st_room =
  temp :: real
(*
  AHU\<^sub>t :: real
  FCU1\<^sub>t :: real
  FCU2\<^sub>t :: real
  Atrium\<^sub>t :: real
*)  

definition ldb :: "st_room upred" where
  "ldb \<equiv> &temp <\<^sub>u 18"
definition udb :: "st_room upred" where
  "udb \<equiv> &temp >\<^sub>u 22"
definition pasdb :: "st_room upred" where
  "pasdb \<equiv> &temp \<ge>\<^sub>u 18 \<and> &temp \<le>\<^sub>u 22"

definition \<alpha>\<^sub>p :: "real" where "\<alpha>\<^sub>p \<equiv> 1"  
definition \<alpha>\<^sub>h :: "real" where "\<alpha>\<^sub>h \<equiv> 1"  
definition \<alpha>\<^sub>c :: "real" where "\<alpha>\<^sub>c \<equiv> 1"  
  
definition \<beta>\<^sub>h :: "real" where "\<beta>\<^sub>h \<equiv> 1"  
definition \<beta>\<^sub>c :: "real" where "\<beta>\<^sub>c \<equiv> 1"  

type_synonym prog = "(st_room, ev_room) action"

term "&temp + 1"
  
definition passive_room :: "prog" where
  [urel_defs]:
  "passive_room \<equiv> env?(Atrium\<^sub>t)?(FCU1\<^sub>t)?(FCU2\<^sub>t)?(AHU\<^sub>t)
   \<^bold>\<rightarrow> temp :=\<^sub>C (&temp + \<guillemotleft>\<alpha>\<^sub>p\<guillemotright> * (\<guillemotleft>Atrium\<^sub>t\<guillemotright> - &temp))
   ;; measure!(&temp) \<^bold>\<rightarrow> Skip"

definition heating_room :: "prog" where
  [urel_defs]:
  "heating_room \<equiv> env?(Atrium\<^sub>t)?(FCU1\<^sub>t)?(FCU2\<^sub>t)?(AHU\<^sub>t)
   \<^bold>\<rightarrow> temp :=\<^sub>C (&temp + \<guillemotleft>\<alpha>\<^sub>h\<guillemotright> * (\<guillemotleft>Atrium\<^sub>t\<guillemotright> - &temp) + \<guillemotleft>\<beta>\<^sub>h\<guillemotright> * (\<guillemotleft>AHU\<^sub>t\<guillemotright> - &temp))
   ;; measure!(&temp) \<^bold>\<rightarrow> Skip"

definition cooling_room :: "prog" where
  [urel_defs]:
  "cooling_room \<equiv> env?(Atrium\<^sub>t)?(FCU1\<^sub>t)?(FCU2\<^sub>t)?(AHU\<^sub>t)
   \<^bold>\<rightarrow> temp :=\<^sub>C (&temp + \<guillemotleft>\<alpha>\<^sub>c\<guillemotright> * (\<guillemotleft>Atrium\<^sub>t\<guillemotright> - &temp) + \<guillemotleft>\<beta>\<^sub>c\<guillemotright> * (\<guillemotleft>AHU\<^sub>t\<guillemotright> - &temp))
   ;; measure!(&temp) \<^bold>\<rightarrow> Skip"
        
abbreviation 
  "DoControl \<equiv> (cooling_room \<triangleleft> udb \<triangleright>\<^sub>R (heating_room \<triangleleft> ldb \<triangleright>\<^sub>R passive_room))"
    
definition Control :: "prog" 
  where [urel_defs]: 
    "Control \<equiv> (\<mu> C \<bullet> DoControl ;; CSP(C))"
  
lemmas room_defs = cooling_room_def heating_room_def passive_room_def Control_def
    
declare image_eqI [closure del]
declare Healthy_set_image_member [closure del]
declare image_subsetI [closure del]  
declare NCSP_Healthy_subset_member [closure del]

method kill = (simp add: rdes closure alpha usubst unrest wp prod.case_eq_if)
  
lemma preR_cooling_room [rdes]: "pre\<^sub>R(cooling_room) = true"
  by (simp add: cooling_room_def, kill)
  
lemma preR_heating_room [rdes]: "pre\<^sub>R(heating_room) = true"
  by (simp add: heating_room_def, kill)

lemma preR_passive_room [rdes]: "pre\<^sub>R(passive_room) = true"
  by (simp add: passive_room_def, kill)

lemma postR_passive_room [rdes]: "post\<^sub>R(DoControl) = undefined"
  apply (simp add: room_defs closure prod.case_eq_if rdes alpha usubst unrest wp)
  oops
  
lemma DoControl_NCSP [closure]: "DoControl is NCSP"
  by (simp add: room_defs closure prod.case_eq_if)
    
lemma DoControl_Productive [closure]: "DoControl is Productive"
  by (simp add: room_defs closure prod.case_eq_if)    
    
lemma Control_NCSP [closure]: "Control is NSRD"
  by (simp add: Control_def closure)
    
lemma postR_Control [rdes]: "post\<^sub>R(Control) = false"
  by (simp add: Control_def rdes closure wp)
  
lemma control_never_terminates: 
  "X is NCSP \<Longrightarrow> Control ;; X \<equiv> Control"
  by (simp_all add: NSRD_seq_post_false closure rdes)
    
abbreviation "ExampleControl \<equiv> (temp :=\<^sub>C 20 ;; Control)"
 
  
(*
lemma preR_RHS_design: 
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P"
"pre\<^sub>R(\<^bold>R\<^sub>s(P \<turnstile> Q)) = (\<not> R1(R2c(pre\<^sub>s \<dagger> (\<not> P))))"
  by (simp add: RHS_def usubst R3h_def pre\<^sub>R_def pre\<^sub>s_design)

lemma rea_cmt_RHS_design: "cmt\<^sub>R(\<^bold>R\<^sub>s(P \<turnstile> Q)) = R1(R2c(cmt\<^sub>s \<dagger> (P \<Rightarrow> Q)))"
  by (simp add: RHS_def usubst R3h_def cmt\<^sub>R_def cmt\<^sub>s_design)

lemma rea_peri_RHS_design: "peri\<^sub>R(\<^bold>R\<^sub>s(P \<turnstile> Q \<diamondop> R)) = R1(R2c(peri\<^sub>s \<dagger> (P \<Rightarrow> Q)))"
  by (simp add:RHS_def usubst peri\<^sub>R_def R3h_def peri\<^sub>s_design)

lemma rea_post_RHS_design: "post\<^sub>R(\<^bold>R\<^sub>s(P \<turnstile> Q \<diamondop> R)) = R1(R2c(post\<^sub>s \<dagger> (P \<Rightarrow> R)))"
  by (simp add:RHS_def usubst post\<^sub>R_def R3h_def post\<^sub>s_design)
*)  

lemma "\<^bold>R\<^sub>s(($st:temp <\<^sub>u 22) \<turnstile> true \<diamondop> (\<^bold>\<forall> a,b,c,d,t \<bullet> (tt =\<^sub>u \<langle>\<guillemotleft>env(a,b,c,d)\<guillemotright>,\<guillemotleft>measure(t)\<guillemotright>\<rangle>) \<and> \<guillemotleft>a\<guillemotright> <\<^sub>u 30 \<and> \<guillemotleft>d\<guillemotright> <\<^sub>u 15 \<Rightarrow> \<guillemotleft>t\<guillemotright> <\<^sub>u 22))
       \<sqsubseteq> DoControl"
  apply (rule SRD_refine_intro)
  apply (simp_all add: closure unrest rdes)
oops
  
end