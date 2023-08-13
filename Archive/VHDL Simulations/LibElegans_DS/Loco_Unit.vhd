----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    C Elegans Locomotion Circuit
-- Project Name:   
-- Target Devices: 
-- Tool versions:  ModelSim SE 6.2F
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;
use LibNeuron.TYPEDEFINITIONS.ALL;

library LibElegans;
use LibElegans.ALL;

entity Loco_Unit is
    port (-- Control Signals
          signal Clock  : in  std_logic;
          signal CKE    : in  std_logic;
          signal nReset : in  std_logic; -- Active Low
          
          -- Loco System Driver Inputs
          signal AVB_Ax   : in std_logic;
          signal AVA_Ax   : in std_logic;
          
          -- Inputs from Forward Muscles
          signal DM_Fwd   : in std_logic;
          signal VM_Fwd   : in std_logic;
          
          -- Inputs from Aft Muscles
          signal DM_Aft   : in std_logic;
          signal VM_Aft   : in std_logic;
          
          -- Muscle Outputs
          signal Neuron_En : in std_logic_vector(7 downto 0);
          
          signal Neuron_Ax : out std_logic_vector(7 downto 0)                
          );
end Loco_Unit;

---------------------------------
-- Architecture for Loco Unit  --
-- which connect to Nerve Ring --
---------------------------------

architecture NerveRing of Loco_Unit is
-- Synaptic Weight Vectors    
signal DB_Syn : signed_vector(0 downto 0);
signal VB_Syn : signed_vector(0 downto 0);

signal DA_Syn : signed_vector(1 downto 0);
signal VA_Syn : signed_vector(1 downto 0);

signal DM_Syn : signed_vector(3 downto 0);
signal VM_Syn : signed_vector(3 downto 0); 

signal DD_Syn : signed_vector(1 downto 0);
signal VD_Syn : signed_vector(1 downto 0);

-- Neuron Axons
signal VB_Ax : std_logic;
signal DB_Ax : std_Logic;

signal VA_Ax : std_logic;
signal DA_Ax : std_Logic; 

signal VD_Ax : std_logic;
signal DD_Ax : std_Logic;

signal VM_Ax : std_logic;
signal DM_Ax : std_Logic;

-- Neuron Resets
signal VB_nReset : std_logic;
signal DB_nReset : std_Logic;

signal VA_nReset : std_logic;
signal DA_nReset : std_Logic; 

signal VD_nReset : std_logic;
signal DD_nReset : std_Logic;

signal VM_nReset : std_logic;
signal DM_nReset : std_Logic;

begin

Neuron_Ax(0) <= DM_Ax;
Neuron_Ax(1) <= DB_Ax;
Neuron_Ax(2) <= DA_Ax;
Neuron_Ax(3) <= DD_Ax;
Neuron_Ax(4) <= VM_Ax;
Neuron_Ax(5) <= VB_Ax;
Neuron_Ax(6) <= VA_Ax;
Neuron_Ax(7) <= VD_Ax;

DM_nReset <= nReset AND Neuron_En(0);
DB_nReset <= nReset AND Neuron_En(1);
DA_nReset <= nReset AND Neuron_En(2); 
DD_nReset <= nReset AND Neuron_En(3);

VM_nReset <= nReset AND Neuron_En(4);
VB_nReset <= nReset AND Neuron_En(5);
VA_nReset <= nReset AND Neuron_En(6);
VD_nReset <= nReset AND Neuron_En(7);


-- Define Neurons
N_VM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(4)
                  port map(Clock, CKE, VM_nReset, VM_Syn, VM_Ax);
N_DM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(4)
                  port map(Clock, CKE, DM_nReset, DM_Syn, DM_Ax);
                  
N_VA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, VA_nReset,  VA_Syn, VA_Ax);
N_VB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(1)
                  port map(Clock, CKE, VB_nReset,  VB_Syn, VB_Ax);
                  
N_DA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, DA_nReset,  DA_Syn, DA_Ax);
N_DB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(1)
                  port map(Clock, CKE, DB_nReset,  DB_Syn, DB_Ax);
                  
N_VD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, VD_nReset,  VD_Syn, VD_Ax);
N_DD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, DD_nReset,  DD_Syn, DD_Ax);

-- Synapses for Dorsal Class B Neuron
S_AVB_DB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, DB_Syn(0));                   

-- Synapses for Ventral Class B Neuron                 
S_AVB_VB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, VB_Syn(0));
                   
-- Synapses for Dorsal Class A Neuron
S_DM_AFT_DA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Aft, DA_Syn(0));
S_AVA_DA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, DA_Syn(1));                   
                   
-- Synapses for Ventral Class A Neurons                   
S_VM_AFT_VA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Aft, VA_Syn(0));
S_AVA_VA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, VA_Syn(1));                       
                       
-- Syanpses for Dorsal Class D Neurons 
S_VB_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Fwd, DD_Syn(0));
S_VA_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VA_Ax, DD_Syn(1));                   

-- Syanpses for Ventral Class D Neurons 
S_DB_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Fwd, VD_Syn(0));
S_DA_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DA_Ax, VD_Syn(1));
                                          
-- Dorsal M Neuron Synapses
S_NRD_DM: entity LibElegans.ElegansSynapse(Type1)
                   port map(Clock, CKE, nReset, DM_Fwd, DM_Syn(0));
S_DB_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DB_Ax, DM_Syn(1));
S_DA_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DA_Ax, DM_Syn(2));
S_DD_DM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, DD_Ax, DM_Syn(3));

-- Ventral M Neuron Synapses
S_NRV_DM: entity LibElegans.ElegansSynapse(Type1)
                   port map(Clock, CKE, nReset, VM_Fwd, VM_Syn(0));                                          
S_VB_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VB_Ax, VM_Syn(1));
S_VA_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VA_Ax, VM_Syn(2));
S_VD_VM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, VD_Ax, VM_Syn(3));
                                                                             
end architecture NerveRing;

-----------------------------------
-- Architecture for Loco Unit    --
-- which connect to Tail section --
-----------------------------------

architecture TailSection of Loco_Unit is
-- Synaptic Weight Vectors    
signal DB_Syn : signed_vector(1 downto 0);
signal VB_Syn : signed_vector(1 downto 0);

signal DA_Syn : signed_vector(0 downto 0);
signal VA_Syn : signed_vector(0 downto 0);

signal DM_Syn : signed_vector(3 downto 0);
signal VM_Syn : signed_vector(3 downto 0); 

signal DD_Syn : signed_vector(1 downto 0);
signal VD_Syn : signed_vector(1 downto 0);

-- Neuron Axons
signal VB_Ax : std_logic;
signal DB_Ax : std_Logic;

signal VA_Ax : std_logic;
signal DA_Ax : std_Logic; 

signal VD_Ax : std_logic;
signal DD_Ax : std_Logic;

signal VM_Ax : std_logic;
signal DM_Ax : std_Logic;

-- Neuron Resets
signal VB_nReset : std_logic;
signal DB_nReset : std_Logic;

signal VA_nReset : std_logic;
signal DA_nReset : std_Logic; 

signal VD_nReset : std_logic;
signal DD_nReset : std_Logic;

signal VM_nReset : std_logic;
signal DM_nReset : std_Logic;
begin

Neuron_Ax(0) <= DM_Ax;
Neuron_Ax(1) <= DB_Ax;
Neuron_Ax(2) <= DA_Ax;
Neuron_Ax(3) <= DD_Ax;
Neuron_Ax(4) <= VM_Ax;
Neuron_Ax(5) <= VB_Ax;
Neuron_Ax(6) <= VA_Ax;
Neuron_Ax(7) <= VD_Ax;

DM_nReset <= nReset AND Neuron_En(0);
DB_nReset <= nReset AND Neuron_En(1);
DA_nReset <= nReset AND Neuron_En(2); 
DD_nReset <= nReset AND Neuron_En(3);

VM_nReset <= nReset AND Neuron_En(4);
VB_nReset <= nReset AND Neuron_En(5);
VA_nReset <= nReset AND Neuron_En(6);
VD_nReset <= nReset AND Neuron_En(7);

    
-- Define Neurons
N_VM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(4)
                  port map(Clock, CKE, VM_nReset, VM_Syn, VM_Ax);
N_DM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(4)
                  port map(Clock, CKE, DM_nReset, DM_Syn, DM_Ax);
                  
N_VA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(1)
                  port map(Clock, CKE, VA_nReset,  VA_Syn, VA_Ax);
N_VB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, VB_nReset,  VB_Syn, VB_Ax);
                  
N_DA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(1)
                  port map(Clock, CKE, DA_nReset,  DA_Syn, DA_Ax);
N_DB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, DB_nReset,  DB_Syn, DB_Ax);
                  
N_VD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, VD_nReset,  VD_Syn, VD_Ax);
N_DD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, DD_nReset,  DD_Syn, DD_Ax);

-- Synapses for Dorsal Class B Neuron
S_DM_FWD_DB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Fwd, DB_Syn(0));
S_AVB_DB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, DB_Syn(1));                   

-- Synapses for Ventral Class B Neuron                 
S_VM_FWD_VB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Fwd, VB_Syn(0));
S_AVB_VB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, VB_Syn(1));
                   
-- Synapses for Dorsal Class A Neuron
--S_DM_AFT_DA: entity LibElegans.ElegansSynapse (Type3)
--                   port map(Clock, nReset, '1', DM_Aft, DA_Syn(0));
S_AVA_DA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, DA_Syn(0));                   
                   
-- Synapses for Ventral Class A Neurons                   
--S_VM_AFT_VA: entity LibElegans.ElegansSynapse (Type3)
--                   port map(Clock, nReset, '1', VM_Aft, VA_Syn(0));
S_AVA_VA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, VA_Syn(0));                       
                       
-- Syanpses for Dorsal Class D Neurons 
S_DB_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VB_Ax, DD_Syn(0));
S_DA_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Aft, DD_Syn(1));                   

-- Syanpses for Ventral Class D Neurons 
S_VB_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DB_Ax, VD_Syn(0));
S_VA_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Aft, VD_Syn(1));
                                          
-- Dorsal M Neuron Synapses
S_DB_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DB_Ax, DM_Syn(0));
S_DA_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DA_Ax, DM_Syn(1));
S_DD_DM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, DD_Ax, DM_Syn(2));
S_TSD_DM: entity LibElegans.ElegansSynapse(Type1)
                   port map(Clock, CKE, nReset, DM_Aft, DM_Syn(3));                   

-- Ventral M Neuron Synapses                                          
S_VB_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VB_Ax, VM_Syn(0));
S_VA_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VA_Ax, VM_Syn(1));
S_VD_VM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, VD_Ax, VM_Syn(2));
S_TSV_DM: entity LibElegans.ElegansSynapse(Type1)
                   port map(Clock, CKE, nReset, VM_Aft, VM_Syn(3));                                                                              
end architecture TailSection;

-----------------------------------------
-- Architecture for Default Loco Unit  --
-----------------------------------------

architecture Default of Loco_Unit is
-- Synaptic Weight Vectors    
signal DB_Syn : signed_vector(1 downto 0);
signal VB_Syn : signed_vector(1 downto 0);

signal DA_Syn : signed_vector(1 downto 0);
signal VA_Syn : signed_vector(1 downto 0);

signal DM_Syn : signed_vector(2 downto 0);
signal VM_Syn : signed_vector(2 downto 0); 

signal DD_Syn : signed_vector(1 downto 0);
signal VD_Syn : signed_vector(1 downto 0);

-- Neuron Axons
signal VB_Ax : std_logic;
signal DB_Ax : std_Logic;

signal VA_Ax : std_logic;
signal DA_Ax : std_Logic; 

signal VD_Ax : std_logic;
signal DD_Ax : std_Logic;

signal VM_Ax : std_logic;
signal DM_Ax : std_Logic;

-- Neuron Resets
signal VB_nReset : std_logic;
signal DB_nReset : std_Logic;

signal VA_nReset : std_logic;
signal DA_nReset : std_Logic; 

signal VD_nReset : std_logic;
signal DD_nReset : std_Logic;

signal VM_nReset : std_logic;
signal DM_nReset : std_Logic;
begin

Neuron_Ax(0) <= DM_Ax;
Neuron_Ax(1) <= DB_Ax;
Neuron_Ax(2) <= DA_Ax;
Neuron_Ax(3) <= DD_Ax;
Neuron_Ax(4) <= VM_Ax;
Neuron_Ax(5) <= VB_Ax;
Neuron_Ax(6) <= VA_Ax;
Neuron_Ax(7) <= VD_Ax;

DM_nReset <= nReset AND Neuron_En(0);
DB_nReset <= nReset AND Neuron_En(1);
DA_nReset <= nReset AND Neuron_En(2); 
DD_nReset <= nReset AND Neuron_En(3);

VM_nReset <= nReset AND Neuron_En(4);
VB_nReset <= nReset AND Neuron_En(5);
VA_nReset <= nReset AND Neuron_En(6);
VD_nReset <= nReset AND Neuron_En(7);

    
-- Define Neurons
-- Define Neurons
N_VM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(3)
                  port map(Clock, CKE, VM_nReset, VM_Syn, VM_Ax);
N_DM: entity LibElegans.ElegansNeuron(CLSM) 
                  generic map(3)
                  port map(Clock, CKE, DM_nReset, DM_Syn, DM_Ax);
                  
N_VA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, VA_nReset,  VA_Syn, VA_Ax);
N_VB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, VB_nReset,  VB_Syn, VB_Ax);
                  
N_DA: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, DA_nReset,  DA_Syn, DA_Ax);
N_DB: entity LibElegans.ElegansNeuron(CLSAB) 
                  generic map(2)
                  port map(Clock, CKE, DB_nReset,  DB_Syn, DB_Ax);
                  
N_VD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, VD_nReset,  VD_Syn, VD_Ax);
N_DD: entity LibElegans.ElegansNeuron(CLSD) 
                  generic map(2)
                  port map(Clock, CKE, DD_nReset,  DD_Syn, DD_Ax);

-- Synapses for Dorsal Class B Neuron
S_DM_FWD_DB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Fwd, DB_Syn(0));
S_AVB_DB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, DB_Syn(1));                   

-- Synapses for Ventral Class B Neuron                 
S_VM_FWD_VB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Fwd, VB_Syn(0));
S_AVB_VB: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVB_Ax, VB_Syn(1));
                   
-- Synapses for Dorsal Class A Neuron
S_DM_AFT_DA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DM_Aft, DA_Syn(0));
S_AVA_DA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, DA_Syn(1));                   
                   
-- Synapses for Ventral Class A Neurons                   
S_VM_AFT_VA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VM_Aft, VA_Syn(0));
S_AVA_VA: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, AVA_Ax, VA_Syn(1));                       
                       
-- Syanpses for Dorsal Class D Neurons 
S_VB_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VB_Ax, DD_Syn(0));
S_VA_DD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, VA_Ax, DD_Syn(1));                   

-- Syanpses for Ventral Class D Neurons 
S_DB_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DB_Ax, VD_Syn(0));
S_DA_VD: entity LibElegans.ElegansSynapse (Type3)
                   port map(Clock, CKE, nReset, DA_Ax, VD_Syn(1));
                                          
-- Dorsal M Neuron Synapses
S_DB_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DB_Ax, DM_Syn(0));
S_DA_DM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, DA_Ax, DM_Syn(1));
S_DD_DM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, DD_Ax, DM_Syn(2));

-- Ventral M Neuron Synapses                                          
S_VB_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VB_Ax, VM_Syn(0));
S_VA_VM: entity LibElegans.ElegansSynapse (Type2)
                   port map(Clock, CKE, nReset, VA_Ax, VM_Syn(1));
S_VD_VM: entity LibElegans.ElegansSynapse (Type4)
                   port map(Clock, CKE, nReset, VD_Ax, VM_Syn(2));                                                    
end architecture Default;
