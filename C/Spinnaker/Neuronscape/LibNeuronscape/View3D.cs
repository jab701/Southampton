using System.Diagnostics;
using System.Windows.Forms;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections;
using System.Collections.Generic;
using Neuronscape;

namespace WinFormsGraphicsDevice
{
    public class View3D : GraphicsDeviceControl
    {
        private DB_ClientObject DB_Objects = null;
        private CartesianVector CameraLocation = new CartesianVector(0.0, 0.0, 0.0);
        private UInt32 _ObjectID = 0;
        private bool DrawEnabled = false;
        private bool IsViewer = false;

        BasicEffect effect;
        Stopwatch timer;

        public void Setup(DB_ClientObject DB_Objects)
        {
            this.DB_Objects = DB_Objects;
        }
        public CartesianVector CameraPosition
        {
            get
            {
                return CameraLocation;
            }
            set
            {
                CameraLocation = value;
            }
        }
        public UInt32 ObjectID
        {
            get
            {
                return this._ObjectID;
            }
            set
            {
                this._ObjectID = value;
            }
        }
        public bool ViewerMode
        {
            get
            {
                return this.IsViewer;
            }
            set
            {
                this.IsViewer = value;
            }
        }

        /// <summary>
        /// Initializes the control.
        /// </summary>
        protected override void Initialize()
        {
            // Create our effect.
            effect = new BasicEffect(GraphicsDevice);

            effect.VertexColorEnabled = true;

            // Start the animation timer.
            timer = Stopwatch.StartNew();

            // Hook the idle event to constantly redraw our animation.
            Application.Idle += delegate { Invalidate(); };
        }


        /// <summary>
        /// Draws the control.
        /// </summary>
        protected override void Draw()
        {
            GraphicsDevice.Clear(Color.Black);

            List<Record_ClientObject> ObjectList = null;

            if (!this.DrawEnabled)
            {
                return;
            }

            try
            {
                ObjectList = this.DB_Objects.FetchAll();
            }
            catch (NullReferenceException)
            {
                return; // Cannot read the database so we return
            }

            // Spin the triangle according to how much time has passed.
            float time = (float)timer.Elapsed.TotalSeconds;

            float yaw = time * 0.7f;
            float pitch = time * 0.8f;
            float roll = time * 0.9f;

            // Set transform matrices.
            float aspect = GraphicsDevice.Viewport.AspectRatio;

            effect.World = Matrix.CreateFromYawPitchRoll(yaw, pitch, roll);

            effect.View = Matrix.CreateLookAt(new Vector3(0, 0, -5),
                                              Vector3.Zero, Vector3.Up);

            effect.Projection = Matrix.CreatePerspectiveFieldOfView(1, aspect, 1, 10);

            // Set renderstates.
            GraphicsDevice.RasterizerState = RasterizerState.CullNone;

            // Draw the triangle.
            effect.CurrentTechnique.Passes[0].Apply();

           // GraphicsDevice.DrawUserPrimitives(PrimitiveType.TriangleList, 
           //                                   Vertices, 0, 1);
        }
    }
}
