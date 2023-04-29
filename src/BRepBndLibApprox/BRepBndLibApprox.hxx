// Updates by: Copyright (c) 2019 Gabriel Cuvillier - Continuation Labs
//  Moved parts of TKTopAlgo/BRepBndLib to TKBRep/BRepBndLibApprox (bounding box using triangulation), to remove a
//  dependency of TKVisualization to TKTopAlgo

#ifndef _BRepBndLibApprox_HeaderFile
#define _BRepBndLibApprox_HeaderFile

#include <Standard.hxx>
#include <Standard_DefineAlloc.hxx>
#include <Standard_Handle.hxx>

#include <Standard_Boolean.hxx>
class TopoDS_Shape;
class Bnd_Box;
class Bnd_OBB;


//! This package provides the bounding boxes for curves
//! and surfaces from BRepAdaptor.
//! Functions to add a topological shape to a bounding box
class BRepBndLibApprox
{
public:

  DEFINE_STANDARD_ALLOC


  //! Adds the shape S to the bounding box B.
  //! More precisely are successively added to B:
  //! -   each face of S; the triangulation of the face is used if it exists,
  //! -   then each edge of S which does not belong to a face,
  //! the polygon of the edge is used if it exists
  //! -   and last each vertex of S which does not belong to an edge.
  //! After each elementary operation, the bounding box B is
  //! enlarged by the tolerance value of the relative sub-shape.
  //! When working with the triangulation of a face this value of
  //! enlargement is the sum of the triangulation deflection and
  //! the face tolerance. When working with the
  //! polygon of an edge this value of enlargement is
  //! the sum of the polygon deflection and the edge tolerance.
  //! Warning
  //! -   This algorithm is time consuming if triangulation has not
  //! been inserted inside the data structure of the shape S.
  //! -   The resulting bounding box may be somewhat larger than the object.
  Standard_EXPORT static void Add (const TopoDS_Shape& S, Bnd_Box& B);

protected:





private:





};







#endif // _BRepBndLibApprox_HeaderFile
