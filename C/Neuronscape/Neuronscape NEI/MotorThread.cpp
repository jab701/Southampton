#include "MotorThread.h"

// Public Functions
// Constructor
MotorThread::MotorThread(wxFrame* Parent) : wxThread(wxTHREAD_JOINABLE)
{
	this->m_Parent = Parent;
	if(MUSCLE_MODEL_IMPULSE){ // debug/experimental mode. RM
		// with proper impulse steps things seem very clunky. 
		// instead, try a rapid decay that has ~3 steps of nonzero force rather than ~150
		//this->m_MuscleForce_Forward = 10000.0;
		//this->m_MuscleForce_Rotate = 5000.0;
		//this->m_MuscleForce_Forward = 300.0;
		//this->m_MuscleForce_Rotate = 300.0;
		//this->m_TimeConst1 = 0.02;  // 1 is for thrust forces
		//this->m_TimeConst2 = 0.02;  // 2 is for rotations
		this->m_MuscleForce_Forward = 5000.0;
		this->m_MuscleForce_Rotate = 1000.0;
		this->m_TimeConst1 = 0.333333333333;
		this->m_TimeConst2 = 0.5;
		this->m_MuscleFwd_Ctr = 0;
		this->m_MuscleSdw_Ctr = 0;
		this->m_MuscleRot_Ctr = 0;

	} else{ // standard muscle model
		this->m_MuscleForce_Forward = 50.0;
		this->m_MuscleForce_Rotate = 10.0;
		this->m_TimeConst1 = 0.333333333333;
		this->m_TimeConst2 = 0.5;
	}
	
	this->m_MuscleForce_Backward = 0.0;
	this->m_MuscleForce_Sideways = 0.0;
	

	this->m_ForceInForwardDirection = 0.0;
	this->m_ForceInSidewayDirection = 0.0;
	this->m_ThetaTorque = 0.0;

	this->m_LastResultant = 0.0;
	this->m_LastThetaTorque = 0.0;

	this->m_NetworkStack = NULL;
	this->m_DB  = NULL;
	this->m_TimeStepMs = 0;


	this->m_Mutex = new wxMutex();
}
// Destructor
MotorThread::~MotorThread()
{
	this->m_MuscleForce_Forward = 0.0;
	this->m_MuscleForce_Backward = 0.0;
	this->m_MuscleForce_Sideways = 0.0;
	this->m_MuscleForce_Rotate = 0.0;

	this->m_ForceInForwardDirection = 0.0;
	this->m_ForceInSidewayDirection = 0.0;
	this->m_ThetaTorque = 0.0;

	this->m_LastResultant = 0.0;
	this->m_LastThetaTorque = 0.0;

	this->m_NetworkStack = NULL;
	this->m_DB  = NULL;
	this->m_TimeStepMs = 0;
	this->m_TimeConst1 = 0.0;
	this->m_TimeConst2 = 0.0;
	delete this->m_Mutex;
	this->m_Mutex = NULL;
}
void MotorThread::CalcMotorForces(DBRecord_ClientObject Record)
{
	SphericalVector Forwards = SphericalVector(this->m_ForceInForwardDirection,Record.Theta,Record.Phi+(PI/2.0));
	SphericalVector Sideways = SphericalVector(this->m_ForceInSidewayDirection,Record.Theta+(PI/2.0),Record.Phi+(PI/2.0));
	SphericalVector Total = Forwards + Sideways;

	this->m_CurrentMotorForce = CartesianVector(Total);

	if (Total.Mag != 0.0)
	{
		this->ForceUpdateMessage();
	}
	else
	{
		if (this->m_LastResultant != 0.0)
		{
			this->ForceUpdateMessage();
		}
	}

	this->m_LastResultant = Total.Mag;
}
void MotorThread::CalcTorqueForces()
{
	this->m_CurrentTorque = this->m_ThetaTorque;

	if (this->m_ThetaTorque != 0.0)
	{
		this->TorqueUpdateMessage();
	}
	else
	{
		if (this->m_LastThetaTorque != 0.0)
		{
			this->TorqueUpdateMessage();
		}
	}

	this->m_LastThetaTorque = this->m_ThetaTorque;
}
void MotorThread::DecayForces()
{
	if(MUSCLE_MODEL_IMPULSE){ // a simple "impulse" muscle output force model: force is high for a single period then falls to zero
		// use this for testing NN-controlled agent behaviours
		if(this->m_MuscleFwd_Ctr > 0){
			if(this->m_ForceInForwardDirection > 0.00001){
				wxLogMessage("Impulse force (fwd) is now %.5lf; ctr=%d; next time will be off", this->m_ForceInForwardDirection, this->m_MuscleFwd_Ctr);
			}
			// next round, unset flag
			this->m_MuscleFwd_Ctr -= 1;
		} else{
			if(this->m_ForceInForwardDirection >  0.00001){ // set flag
				this->m_MuscleFwd_Ctr =IMPULSE_FORCE_DURATION;
			}
		}
		if(this->m_MuscleFwd_Ctr == 0){
			//this->m_ForceInForwardDirection -= this->m_MuscleForce_Forward;
			this->m_ForceInForwardDirection =0; // -= this->m_MuscleForce_Forward;
		}
		// sideways muscle (??)
		if(this->m_MuscleSdw_Ctr > 0){
			if(this->m_ForceInSidewayDirection > 0.00001){
				wxLogMessage("Impulse force (sdw) is now %.5lf; ctr=%d; next time will be off", this->m_ForceInSidewayDirection, this->m_MuscleSdw_Ctr);
			}
			// next round, unset flag
			this->m_MuscleSdw_Ctr -= 1;
		} else{
			if(this->m_ForceInSidewayDirection >  0.00001){ // set flag
				this->m_MuscleSdw_Ctr =IMPULSE_FORCE_DURATION;
			}
		}
		if(this->m_MuscleSdw_Ctr == 0){
			this->m_ForceInSidewayDirection =0; // -= this->m_MuscleForce_Forward;
		}
		// rotational forces
		if(this->m_MuscleRot_Ctr > 0){
			if(abs( this->m_ThetaTorque) > 0.00001 ){
				wxLogMessage("Impulse force (rot) is now %.5lf; ctr=%d; next time will be off", this->m_ThetaTorque, this->m_MuscleRot_Ctr);
			}
			// next round, unset flag
			this->m_MuscleRot_Ctr -= 1;
		} else{
			if(abs(this->m_ThetaTorque) >  0.00001){ // set flag
				this->m_MuscleRot_Ctr =IMPULSE_TORQUE_DURATION;
			}
		}
		if(this->m_MuscleRot_Ctr == 0){
			this->m_ThetaTorque =0; // -= this->m_MuscleForce_Forward;
		}


		//this->m_ThetaTorque = m_ThetaTorque*0.5; // halve it every interrupt period

	}
	else{
		// the original decaying forces model
		double Decay1 = (-1.0*this->m_TimeStepMs*1E-3)/this->m_TimeConst1;
		double Decay2 = (-1.0*this->m_TimeStepMs*1E-3)/this->m_TimeConst2;

		this->m_ForceInForwardDirection = this->m_ForceInForwardDirection*(std::exp(Decay1));
		this->m_ForceInSidewayDirection = this->m_ForceInSidewayDirection*(std::exp(Decay1));

		if (this->m_ThetaTorque != 0.0)
		{
			this->m_ThetaTorque = this->m_ThetaTorque*(std::exp(Decay2));
		}
	}

}
void MotorThread::ForwardBackwardMuscle(bool Backwards)
{
	wxMutexLocker(*this->m_Mutex);
	if (wxThread::IsMain())
	{
		if (Backwards == true)
		{
			if (this->m_ForceInForwardDirection < 0.0)
			{
				this->m_ForceInForwardDirection -= this->m_MuscleForce_Backward;
			}
			else
			{
				this->m_ForceInForwardDirection = -this->m_MuscleForce_Backward;
			}
		}
		else
		{
			if (this->m_ForceInForwardDirection > 0.0)
			{
				this->m_ForceInForwardDirection += this->m_MuscleForce_Forward;
			}
			else
			{
				this->m_ForceInForwardDirection = this->m_MuscleForce_Forward;
			}
		}
	}
}
void MotorThread::Initialize(wxIPV4address ServerAddress, DB_ClientObject *DB, uint32_t ObjectID, int TimeStepMs)
{
	this->m_ServerAddress = ServerAddress;
	this->m_DB = DB;
	this->m_TimeStepMs = TimeStepMs;
	this->m_ObjectID = ObjectID;
}
void MotorThread::RotateTheta(bool AntiClockwise)
{
	wxMutexLocker(*this->m_Mutex);
	if (wxThread::IsMain())
	{
		if (AntiClockwise == true)
		{
			if (this->m_ThetaTorque < 0.0)
			{
				this->m_ThetaTorque -= this->m_MuscleForce_Rotate;
			}
			else
			{
				this->m_ThetaTorque = -this->m_MuscleForce_Rotate;
			}
		}
		else
		{
			if (this->m_ThetaTorque > 0.0)
			{
				this->m_ThetaTorque += this->m_MuscleForce_Rotate;
			}
			else
			{
				this->m_ThetaTorque = this->m_MuscleForce_Rotate;
			}
		}
	}
}
void MotorThread::SidewaysMuscle(bool Left)
{
	wxMutexLocker(*this->m_Mutex);
	if (wxThread::IsMain())
	{
		if (Left == true)
		{
			if (this->m_ForceInSidewayDirection < 0.0)
			{
				this->m_ForceInSidewayDirection -= this->m_MuscleForce_Sideways;
			}
			else
			{
				this->m_ForceInSidewayDirection = -this->m_MuscleForce_Sideways;
			}
		}
		else
		{
			if (this->m_ForceInSidewayDirection > 0.0)
			{
				this->m_ForceInSidewayDirection += this->m_MuscleForce_Sideways;
			}
			else
			{
				this->m_ForceInSidewayDirection = this->m_MuscleForce_Sideways;
			}
		}
	}
}

void MotorThread::GetObjectForces(unsigned &ObjectID, CartesianVector &MotorForce)
{
	wxMutexLocker lock(*this->m_Mutex);
	ObjectID = this->m_ObjectID;
	MotorForce = this->m_CurrentMotorForce;
}
void MotorThread::GetObjectTorque(unsigned &ObjectID, double &TorqueForce)
{
	wxMutexLocker lock(*this->m_Mutex);
	ObjectID = this->m_ObjectID;
	TorqueForce = this->m_CurrentTorque;
}
void MotorThread::ForceUpdateMessage()
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_FORCES_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(this->m_ObjectID);
	std::vector<unsigned char> X = double2uchar(this->m_CurrentMotorForce.x);
	std::vector<unsigned char> Y = double2uchar(this->m_CurrentMotorForce.y);
	std::vector<unsigned char> Z = double2uchar(this->m_CurrentMotorForce.z);

	Message.append(ID.begin(), ID.end());
	Message.append(OID.begin(), OID.end());
	Message.append(X.begin(), X.end());
	Message.append(Y.begin(), Y.end());
	Message.append(Z.begin(), Z.end());

	TransmitThreadNetworkPacketEvent event (nsTXMOTORFORCEUPDATE, ID_MOTOR_FORCE_UPDATE);
	event.SetAddress(this->m_ServerAddress);
	event.SetPayload(Message);

	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
void MotorThread::TorqueUpdateMessage()
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_TORQUE_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(this->m_ObjectID);
	std::vector<unsigned char> T = double2uchar(this->m_CurrentTorque);
	std::vector<unsigned char> P = double2uchar(0.0);
	
	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());
	Message.append(T.begin(),T.end());
	Message.append(P.begin(),P.end());

	TransmitThreadNetworkPacketEvent event (nsTXMOTORFORCEUPDATE, ID_MOTOR_FORCE_UPDATE);
	event.SetAddress(this->m_ServerAddress);
	event.SetPayload(Message);

	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
// Private Functions
wxThread::ExitCode MotorThread::Entry()
{
	//if (this->m_NetworkStack == NULL)
	//{
	//	wxLogMessage("Motorthread Exit 1");
	//	return (wxThread::ExitCode)1;
	//}

	if (this->m_DB == NULL)
	{
		wxLogMessage("Motorthread Exit 2");
		return (wxThread::ExitCode)2;
	}

	if (this->m_ObjectID == 0)
	{
		wxLogMessage("Motorthread Exit 3");
		return (wxThread::ExitCode)3;
	}

	if (this->m_TimeStepMs == 0)
	{
		wxLogMessage("Motorthread Exit 4");
		return (wxThread::ExitCode)4;
	}
	wxLogMessage("Motorthread Running");
	while (1)
	{
		if (this->TestDestroy())
		{
			wxLogMessage("MotorThread Exit");
			break;
		}

		DBRecord_ClientObject Record;

		if (this->m_DB->FindByID(this->m_ObjectID,Record))
		{
			if (!(Record.Energy <= 0.0))
			{
				this->m_Mutex->Lock();

				// program a new muscle model here?

				this->CalcMotorForces(Record);
				this->CalcTorqueForces();
				this->DecayForces();

				this->m_Mutex->Unlock();
			}
		}
		else
		{
			//wxLogMessage("Motorthread out of energy");
		}

		this->Sleep(this->m_TimeStepMs);
	}
	return (wxThread::ExitCode) 0;
}